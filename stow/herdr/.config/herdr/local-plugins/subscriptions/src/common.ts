import { execFile } from 'node:child_process'
import { readFile } from 'node:fs/promises'
import { promisify } from 'node:util'
import { Effect, Schema } from 'effect'

const executeFile = promisify(execFile)

export class SubscriptionError extends Schema.TaggedError<SubscriptionError>()(
  'SubscriptionError',
  {
    provider: Schema.String,
    message: Schema.String,
    cause: Schema.optional(Schema.Defect()),
  },
) {}

export const readText = Effect.fn('readText')(
  (provider: string, path: string) =>
    Effect.tryPromise({
      try: () => readFile(path, 'utf8'),
      catch: (cause) =>
        new SubscriptionError({
          provider,
          message: `Could not read ${path}`,
          cause,
        }),
    }),
)

export const run = Effect.fn('run')(
  (provider: string, command: string, args: ReadonlyArray<string>) =>
    Effect.tryPromise({
      try: async () => {
        const result = await executeFile(command, [...args], {
          encoding: 'utf8',
          timeout: 5_000,
          maxBuffer: 1024 * 1024,
        })
        return result.stdout.trim()
      },
      catch: (cause) =>
        new SubscriptionError({
          provider,
          message: `Could not run ${command}`,
          cause,
        }),
    }),
)

export const requestJson = Effect.fn('requestJson')(
  (provider: string, url: string, init: RequestInit) =>
    Effect.tryPromise({
      try: async () => {
        const response = await fetch(url, {
          ...init,
          redirect: 'error',
          signal: AbortSignal.timeout(15_000),
        })
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return (await response.json()) as unknown
      },
      catch: (cause) =>
        new SubscriptionError({
          provider,
          message: `${provider} usage request failed: ${String(cause)}`,
          cause,
        }),
    }),
)

export const decode = <A, I>(
  provider: string,
  schema: Schema.Codec<A, I, never>,
  input: unknown,
): Effect.Effect<A, SubscriptionError> =>
  Schema.decodeUnknownEffect(schema)(input).pipe(
    Effect.mapError(
      (cause) =>
        new SubscriptionError({
          provider,
          message: `${provider} returned an unexpected response`,
          cause,
        }),
    ),
  )
