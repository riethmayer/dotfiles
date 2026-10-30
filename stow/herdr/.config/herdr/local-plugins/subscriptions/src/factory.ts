import { createDecipheriv } from 'node:crypto'
import { homedir } from 'node:os'
import { join } from 'node:path'
import { Clock, Effect, Schema } from 'effect'
import { decode, readText, requestJson, SubscriptionError } from './common.js'
import {
  clampPercent,
  parseTimestamp,
  type ProviderReport,
  type UsageWindow,
} from './model.js'

const Provider = 'Droid'
const GlobalUrl = 'https://api.factory.ai/api/billing/limits'
const EuUrl = 'https://api.eu.factory.ai/api/billing/limits'

const Login = Schema.Struct({
  access_token: Schema.NonEmptyString,
  active_organization_id: Schema.optional(Schema.NullOr(Schema.String)),
  whoami: Schema.optional(
    Schema.NullOr(
      Schema.Struct({
        region: Schema.optional(
          Schema.NullOr(Schema.Literals(['global', 'eu'])),
        ),
      }),
    ),
  ),
  region: Schema.optional(Schema.NullOr(Schema.Literals(['global', 'eu']))),
})

const BillingWindow = Schema.Struct({
  usedPercent: Schema.Number,
  windowEnd: Schema.optional(
    Schema.NullOr(Schema.Union([Schema.String, Schema.Number])),
  ),
  secondsRemaining: Schema.optional(Schema.NullOr(Schema.Number)),
})

const Pool = Schema.Struct({
  fiveHour: Schema.optional(Schema.NullOr(BillingWindow)),
  weekly: Schema.optional(Schema.NullOr(BillingWindow)),
  monthly: Schema.optional(Schema.NullOr(BillingWindow)),
})

const Billing = Schema.Struct({
  limits: Schema.Struct({
    standard: Schema.optional(Schema.NullOr(Pool)),
    core: Schema.optional(Schema.NullOr(Pool)),
  }),
  extraUsageBalanceCents: Schema.optional(Schema.Number),
})

type WindowInput = typeof BillingWindow.Type

type LoginData = typeof Login.Type

export const decryptLogin = (
  encrypted: string,
  encodedKey: string,
): Effect.Effect<unknown, SubscriptionError> =>
  Effect.try({
    try: () => {
      const parts = encrypted.trim().split(':')
      const key = Buffer.from(encodedKey.trim(), 'base64')
      if (parts.length !== 3 || key.length !== 32)
        throw new Error('Invalid credential store')
      const [ivText, tagText, dataText] = parts
      if (!ivText || !tagText || !dataText)
        throw new Error('Invalid credential store')
      const decipher = createDecipheriv(
        'aes-256-gcm',
        key,
        Buffer.from(ivText, 'base64'),
      )
      decipher.setAuthTag(Buffer.from(tagText, 'base64'))
      const plaintext = Buffer.concat([
        decipher.update(Buffer.from(dataText, 'base64')),
        decipher.final(),
      ]).toString('utf8')
      return JSON.parse(plaintext) as unknown
    },
    catch: (cause) =>
      new SubscriptionError({
        provider: Provider,
        message: 'Could not decrypt the Droid login',
        cause,
      }),
  })

const readLogin = Effect.fn('readLogin')(function* (): Effect.fn.Return<
  LoginData,
  SubscriptionError
> {
  const root = process.env.FACTORY_HOME_OVERRIDE ?? join(homedir(), '.factory')
  const [encrypted, key] = yield* Effect.all(
    [
      readText(Provider, join(root, 'auth.v2.file')),
      readText(Provider, join(root, 'auth.v2.key')),
    ],
    { concurrency: 'unbounded' },
  )
  const unknown = yield* decryptLogin(encrypted, key)
  return yield* decode(Provider, Login, unknown)
})

const resetAt = (window: WindowInput, now: number): number | undefined => {
  if (window.secondsRemaining && window.secondsRemaining > 0) {
    return now + window.secondsRemaining * 1000
  }
  const absolute = parseTimestamp(window.windowEnd)
  return absolute && absolute > now ? absolute : undefined
}

const poolWindows = (
  pool: typeof Pool.Type | null | undefined,
  prefix: string,
  now: number,
): Array<UsageWindow> => {
  if (!pool) return []
  const windows: ReadonlyArray<
    readonly [string, WindowInput | null | undefined]
  > = [
    ['5 hours', pool.fiveHour],
    ['7 days', pool.weekly],
    ['30 days', pool.monthly],
  ]
  return windows.flatMap(([label, window]) => {
    if (!window) return []
    const resetsAt = resetAt(window, now)
    const usedPercent =
      resetsAt === undefined &&
      window.windowEnd != null &&
      window.secondsRemaining == null
        ? 0
        : clampPercent(window.usedPercent)
    return [
      {
        label: prefix ? `${prefix} · ${label}` : label,
        usedPercent,
        ...(resetsAt === undefined ? {} : { resetsAt }),
      },
    ]
  })
}

export const fetchFactory = Effect.fn('fetchFactory')(
  function* (): Effect.fn.Return<ProviderReport, SubscriptionError> {
    const login = yield* readLogin()
    const now = yield* Clock.currentTimeMillis
    const region = login.whoami?.region ?? login.region ?? 'global'
    const headers: Record<string, string> = {
      Authorization: `Bearer ${login.access_token}`,
      Accept: 'application/json',
      'X-Factory-Client': 'cli',
    }
    if (login.active_organization_id) {
      headers['X-Factory-Org-Id'] = login.active_organization_id
    }
    const raw = yield* requestJson(
      Provider,
      region === 'eu' ? EuUrl : GlobalUrl,
      { headers },
    )
    const billing = yield* decode(Provider, Billing, raw)
    const windows = [
      ...poolWindows(billing.limits.standard, 'Standard', now),
      ...poolWindows(billing.limits.core, 'Core', now),
    ]
    const balance = billing.extraUsageBalanceCents

    return {
      name: Provider,
      windows,
      ...(balance === undefined
        ? {}
        : { balance: `Extra Usage balance: $${(balance / 100).toFixed(2)}` }),
      source: 'Factory billing API',
      updatedAt: now,
    }
  },
)
