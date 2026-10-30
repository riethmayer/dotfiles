import { homedir } from 'node:os'
import { join } from 'node:path'
import { Clock, Effect, Schema } from 'effect'
import { decode, readText, run, SubscriptionError } from './common.js'
import { clampPercent, type ProviderReport } from './model.js'

const Provider = 'Claude API'
const DefaultBaseUrl = 'https://api.anthropic.com'
const DefaultModel = 'claude-haiku-4-5'

const Account = Schema.Struct({
  name: Schema.NonEmptyString,
  credentialRef: Schema.NonEmptyString,
  baseUrl: Schema.optional(Schema.NonEmptyString),
  model: Schema.optional(Schema.NonEmptyString),
  auth: Schema.optional(Schema.Literals(['x-api-key', 'bearer'])),
})

const Config = Schema.Struct({
  anthropicApiKeys: Schema.optional(Schema.Array(Account)),
})

type AccountData = typeof Account.Type

const configPath = (): string =>
  join(
    process.env.HERDR_PLUGIN_CONFIG_DIR ??
      join(homedir(), '.config/herdr/plugins/config/subscriptions'),
    'accounts.json',
  )

const readAccounts = Effect.fn('readApiKeyAccounts')(
  function* (): Effect.fn.Return<
    ReadonlyArray<AccountData>,
    SubscriptionError
  > {
    const text = yield* Effect.option(readText(Provider, configPath()))
    if (text._tag === 'None') return []
    const unknown = yield* Effect.try({
      try: () => JSON.parse(text.value) as unknown,
      catch: (cause) =>
        new SubscriptionError({
          provider: Provider,
          message: `Could not parse ${configPath()}`,
          cause,
        }),
    })
    const config = yield* decode(Provider, Config, unknown)
    return config.anthropicApiKeys ?? []
  },
)

const readCredential = Effect.fn('readApiKeyCredential')(function* (
  reference: string,
): Effect.fn.Return<string, SubscriptionError> {
  if (!reference.startsWith('op://')) {
    return yield* new SubscriptionError({
      provider: Provider,
      message: 'API key credentials must use an op:// reference',
    })
  }

  const serviceToken =
    process.env.OP_SERVICE_ACCOUNT_TOKEN ??
    (yield* run(Provider, '/usr/bin/security', [
      'find-generic-password',
      '-s',
      'op-service-account-token',
      '-w',
    ]))
  const op =
    process.env.OP_BIN ??
    join(homedir(), '.local/share/mise/installs/1password/latest/op')
  return yield* run(Provider, op, ['read', reference], {
    env: { ...process.env, OP_SERVICE_ACCOUNT_TOKEN: serviceToken },
    timeout: 10_000,
  })
})

interface RateLimit {
  readonly name: string
  readonly limit: number
  readonly remaining: number
  readonly resetsAt?: number
}

const integerHeader = (headers: Headers, name: string): number | undefined => {
  const raw = headers.get(name)
  if (raw === null || raw.trim() === '') return undefined
  const value = Number(raw)
  return Number.isSafeInteger(value) && value >= 0 ? value : undefined
}

export const parseRateLimitHeaders = (
  headers: Headers,
): ReadonlyArray<RateLimit> => {
  const definitions: ReadonlyArray<readonly [string, string]> = [
    ['Requests', 'requests'],
    ['Input tokens', 'input-tokens'],
    ['Output tokens', 'output-tokens'],
    ['Total tokens', 'tokens'],
  ]

  return definitions.flatMap(([name, key]) => {
    const prefix = `anthropic-ratelimit-${key}`
    const limit = integerHeader(headers, `${prefix}-limit`)
    const remaining = integerHeader(headers, `${prefix}-remaining`)
    if (limit === undefined || remaining === undefined || limit === 0) return []
    const reset = headers.get(`${prefix}-reset`)
    const resetsAt = reset ? Date.parse(reset) : Number.NaN
    return [
      {
        name,
        limit,
        remaining,
        ...(Number.isFinite(resetsAt) ? { resetsAt } : {}),
      },
    ]
  })
}

const probeAccount = Effect.fn('probeApiKeyAccount')(function* (
  account: AccountData,
): Effect.fn.Return<ProviderReport, SubscriptionError> {
  const credential = yield* readCredential(account.credentialRef)
  const baseUrl = (account.baseUrl ?? DefaultBaseUrl)
    .replace(/\/$/u, '')
    .replace(/\/v1$/u, '')
  const auth = account.auth ?? 'x-api-key'
  const response = yield* Effect.tryPromise({
    try: () =>
      fetch(`${baseUrl}/v1/messages`, {
        method: 'POST',
        redirect: 'error',
        signal: AbortSignal.timeout(15_000),
        headers: {
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
          ...(auth === 'bearer'
            ? { authorization: `Bearer ${credential}` }
            : { 'x-api-key': credential }),
        },
        body: JSON.stringify({
          model: account.model ?? DefaultModel,
          max_tokens: 1,
          messages: [{ role: 'user', content: '.' }],
        }),
      }),
    catch: (cause) =>
      new SubscriptionError({
        provider: account.name,
        message: `${account.name} rate-limit probe failed`,
        cause,
      }),
  })
  const limits = parseRateLimitHeaders(response.headers)
  yield* Effect.promise(() => response.body?.cancel() ?? Promise.resolve())
  if (!response.ok) {
    return yield* new SubscriptionError({
      provider: account.name,
      message: `${account.name} rate-limit probe failed: HTTP ${response.status}`,
    })
  }
  if (limits.length === 0) {
    return yield* new SubscriptionError({
      provider: account.name,
      message: `${account.name} returned no rate-limit headers`,
    })
  }

  const updatedAt = yield* Clock.currentTimeMillis
  return {
    name: account.name,
    plan: 'API key',
    windows: limits.map(({ name, limit, remaining, resetsAt }) => ({
      label: `${name} (${remaining.toLocaleString()} / ${limit.toLocaleString()})`,
      usedPercent: clampPercent(((limit - remaining) / limit) * 100),
      ...(resetsAt === undefined ? {} : { resetsAt }),
    })),
    note: 'Rate limits from a one-token Haiku probe',
    source: 'Anthropic response headers',
    updatedAt,
  }
})

const failedAccount = (name: string) =>
  Effect.fnUntraced(function* (error: {
    readonly message: string
  }): Effect.fn.Return<ProviderReport> {
    const updatedAt = yield* Clock.currentTimeMillis
    return {
      name,
      plan: 'API key',
      windows: [],
      source: 'Anthropic response headers',
      updatedAt,
      error: error.message,
    }
  })

export const fetchApiKeyAccounts = Effect.fn('fetchApiKeyAccounts')(
  function* (): Effect.fn.Return<
    ReadonlyArray<ProviderReport>,
    SubscriptionError
  > {
    const accounts = yield* readAccounts()
    return yield* Effect.all(
      accounts.map((account) =>
        probeAccount(account).pipe(Effect.catch(failedAccount(account.name))),
      ),
      { concurrency: 'unbounded' },
    )
  },
)
