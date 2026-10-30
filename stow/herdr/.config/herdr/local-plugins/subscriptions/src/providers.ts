import { Clock, Effect } from 'effect'
import { fetchApiKeyAccounts } from './api-keys.js'
import { fetchClaude } from './claude.js'
import { fetchCodex } from './codex.js'
import { fetchFactory } from './factory.js'
import type { ProviderReport } from './model.js'

const failed = (name: string) =>
  Effect.fnUntraced(function* (error: {
    readonly message: string
  }): Effect.fn.Return<ProviderReport> {
    const updatedAt = yield* Clock.currentTimeMillis
    return {
      name,
      windows: [],
      source: 'Unavailable',
      updatedAt,
      error: error.message,
    }
  })

export const fetchSubscriptions = Effect.fn('fetchSubscriptions')(
  function* (): Effect.fn.Return<ReadonlyArray<ProviderReport>> {
    const [subscriptions, apiKeys] = yield* Effect.all(
      [
        Effect.all(
          [
            fetchCodex().pipe(Effect.catch(failed('Codex'))),
            fetchClaude().pipe(Effect.catch(failed('Claude'))),
            fetchFactory().pipe(Effect.catch(failed('Droid'))),
          ],
          { concurrency: 'unbounded' },
        ),
        fetchApiKeyAccounts().pipe(
          Effect.catch((error) =>
            failed('Claude API keys')(error).pipe(
              Effect.map((report) => [report]),
            ),
          ),
        ),
      ],
      { concurrency: 'unbounded' },
    )
    return [...subscriptions, ...apiKeys]
  },
)
