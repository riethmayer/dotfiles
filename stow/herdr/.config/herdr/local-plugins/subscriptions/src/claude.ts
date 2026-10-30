import { homedir } from 'node:os'
import { join } from 'node:path'
import { Clock, Effect, Schema } from 'effect'
import {
  decode,
  readText,
  requestJson,
  run,
  SubscriptionError,
} from './common.js'
import {
  clampPercent,
  parseTimestamp,
  type ProviderReport,
  titleCase,
  type UsageWindow,
} from './model.js'

const Provider = 'Claude'
const UsageUrl = 'https://api.anthropic.com/api/oauth/usage'

const Credentials = Schema.Struct({
  claudeAiOauth: Schema.Struct({
    accessToken: Schema.NonEmptyString,
    subscriptionType: Schema.optional(Schema.String),
    rateLimitTier: Schema.optional(Schema.String),
  }),
})

const FixedWindow = Schema.Struct({
  utilization: Schema.Number,
  resets_at: Schema.optional(Schema.NullOr(Schema.String)),
})

const Usage = Schema.Struct({
  limits: Schema.optional(
    Schema.NullOr(
      Schema.Array(
        Schema.Struct({
          kind: Schema.String,
          percent: Schema.optional(Schema.Number),
          resets_at: Schema.optional(Schema.NullOr(Schema.String)),
          scope: Schema.optional(
            Schema.NullOr(
              Schema.Struct({
                model: Schema.optional(
                  Schema.NullOr(
                    Schema.Struct({
                      display_name: Schema.optional(Schema.String),
                    }),
                  ),
                ),
              }),
            ),
          ),
        }),
      ),
    ),
  ),
  five_hour: Schema.optional(Schema.NullOr(FixedWindow)),
  seven_day: Schema.optional(Schema.NullOr(FixedWindow)),
})

const credentialsText = Effect.fn('credentialsText')(
  function* (): Effect.fn.Return<string, SubscriptionError> {
    if (process.platform === 'darwin') {
      const user = process.env.USER
      if (user) {
        const byAccount = run(Provider, '/usr/bin/security', [
          'find-generic-password',
          '-s',
          'Claude Code-credentials',
          '-a',
          user,
          '-w',
        ])
        const result = yield* Effect.option(byAccount)
        if (result._tag === 'Some') return result.value
      }

      const byService = yield* Effect.option(
        run(Provider, '/usr/bin/security', [
          'find-generic-password',
          '-s',
          'Claude Code-credentials',
          '-w',
        ]),
      )
      if (byService._tag === 'Some') return byService.value
    }

    const configDir =
      process.env.CLAUDE_CONFIG_DIR ?? join(homedir(), '.claude')
    return yield* readText(Provider, join(configDir, '.credentials.json'))
  },
)

export const fetchClaude = Effect.fn('fetchClaude')(
  function* (): Effect.fn.Return<ProviderReport, SubscriptionError> {
    const text = yield* credentialsText()
    const unknown = yield* Effect.try({
      try: () => JSON.parse(text) as unknown,
      catch: (cause) =>
        new SubscriptionError({
          provider: Provider,
          message: 'Claude credentials are invalid JSON',
          cause,
        }),
    })
    const credentials = yield* decode(Provider, Credentials, unknown)
    const oauth = credentials.claudeAiOauth
    const raw = yield* requestJson(Provider, UsageUrl, {
      headers: {
        Authorization: `Bearer ${oauth.accessToken}`,
        Accept: 'application/json',
        'anthropic-beta': 'oauth-2025-04-20',
        'User-Agent': 'claude-code/2.1.0',
      },
    })
    const usage = yield* decode(Provider, Usage, raw)

    const currentWindows: Array<UsageWindow> = []
    for (const limit of usage.limits ?? []) {
      if (limit.percent === undefined) continue
      const model = limit.scope?.model?.display_name
      const label =
        limit.kind === 'session'
          ? '5 hours'
          : limit.kind === 'weekly_all'
            ? '7 days'
            : limit.kind === 'weekly_scoped' && model
              ? `${model} · 7 days`
              : undefined
      if (!label) continue
      const resetsAt = parseTimestamp(limit.resets_at)
      currentWindows.push({
        label,
        usedPercent: clampPercent(limit.percent),
        ...(resetsAt === undefined ? {} : { resetsAt }),
      })
    }

    const fallbackWindows: Array<UsageWindow> = []
    for (const [label, limit] of [
      ['5 hours', usage.five_hour],
      ['7 days', usage.seven_day],
    ] as const) {
      if (!limit) continue
      const resetsAt = parseTimestamp(limit.resets_at)
      fallbackWindows.push({
        label,
        usedPercent: clampPercent(limit.utilization),
        ...(resetsAt === undefined ? {} : { resetsAt }),
      })
    }

    const plan = oauth.subscriptionType ? titleCase(oauth.subscriptionType) : ''
    const updatedAt = yield* Clock.currentTimeMillis

    return {
      name: Provider,
      ...(plan ? { plan } : {}),
      windows: currentWindows.length > 0 ? currentWindows : fallbackWindows,
      source: 'Claude usage API',
      updatedAt,
    }
  },
)
