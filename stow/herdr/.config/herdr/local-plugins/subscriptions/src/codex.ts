import { homedir } from 'node:os'
import { join } from 'node:path'
import { Clock, Effect, Schema } from 'effect'
import { decode, readText, requestJson, SubscriptionError } from './common.js'
import {
  clampPercent,
  parseTimestamp,
  type ProviderReport,
  titleCase,
  type UsageWindow,
} from './model.js'

const Provider = 'Codex'
const UsageUrl = 'https://chatgpt.com/backend-api/wham/usage'

const Auth = Schema.Struct({
  tokens: Schema.Struct({
    access_token: Schema.NonEmptyString,
    account_id: Schema.optional(Schema.NonEmptyString),
  }),
})

const LimitWindow = Schema.Struct({
  used_percent: Schema.Number,
  limit_window_seconds: Schema.optional(Schema.Number),
  reset_at: Schema.optional(
    Schema.NullOr(Schema.Union([Schema.String, Schema.Number])),
  ),
})

const Limits = Schema.Struct({
  primary_window: Schema.optional(Schema.NullOr(LimitWindow)),
  secondary_window: Schema.optional(Schema.NullOr(LimitWindow)),
})

const Usage = Schema.Struct({
  email: Schema.optional(Schema.String),
  plan_type: Schema.optional(Schema.String),
  rate_limit: Schema.optional(Schema.NullOr(Limits)),
  rate_limit_reset_credits: Schema.optional(
    Schema.NullOr(
      Schema.Struct({
        available_count: Schema.Number,
      }),
    ),
  ),
})

type Limit = typeof LimitWindow.Type

const planLabel = (plan: string): string =>
  plan.toLowerCase() === 'prolite' ? 'Pro' : titleCase(plan)

const durationLabel = (
  seconds: number | undefined,
  fallback: string,
): string => {
  if (!seconds) return fallback
  if (Math.abs(seconds - 5 * 60 * 60) <= 60) return '5 hours'
  if (Math.abs(seconds - 7 * 24 * 60 * 60) <= 60) return '7 days'
  if (seconds % (24 * 60 * 60) === 0) return `${seconds / (24 * 60 * 60)} days`
  return `${Math.round(seconds / (60 * 60))} hours`
}

const toWindow = (limit: Limit, fallback: string): UsageWindow => {
  const resetsAt = parseTimestamp(limit.reset_at)
  return {
    label: durationLabel(limit.limit_window_seconds, fallback),
    usedPercent: clampPercent(limit.used_percent),
    ...(resetsAt === undefined ? {} : { resetsAt }),
  }
}

export const fetchCodex = Effect.fn('fetchCodex')(
  function* (): Effect.fn.Return<ProviderReport, SubscriptionError> {
    const authPath = join(
      process.env.CODEX_HOME ?? join(homedir(), '.codex'),
      'auth.json',
    )
    const authText = yield* readText(Provider, authPath)
    const authUnknown = yield* Effect.try({
      try: () => JSON.parse(authText) as unknown,
      catch: (cause) =>
        new SubscriptionError({
          provider: Provider,
          message: 'Codex auth is invalid JSON',
          cause,
        }),
    })
    const auth = yield* decode(Provider, Auth, authUnknown)

    const headers: Record<string, string> = {
      Authorization: `Bearer ${auth.tokens.access_token}`,
      Accept: 'application/json',
      'User-Agent': 'codex-cli',
    }
    if (auth.tokens.account_id)
      headers['ChatGPT-Account-Id'] = auth.tokens.account_id

    const raw = yield* requestJson(Provider, UsageUrl, { headers })
    const usage = yield* decode(Provider, Usage, raw)
    const windows = [
      usage.rate_limit?.primary_window
        ? toWindow(usage.rate_limit.primary_window, '5 hours')
        : undefined,
      usage.rate_limit?.secondary_window
        ? toWindow(usage.rate_limit.secondary_window, '7 days')
        : undefined,
    ].filter((window): window is UsageWindow => window !== undefined)
    const resets = usage.rate_limit_reset_credits?.available_count
    const updatedAt = yield* Clock.currentTimeMillis

    return {
      name: Provider,
      ...(usage.plan_type ? { plan: planLabel(usage.plan_type) } : {}),
      windows,
      ...(resets === undefined
        ? {}
        : { note: `${resets} account limit resets available` }),
      source: 'Codex account API',
      updatedAt,
    }
  },
)
