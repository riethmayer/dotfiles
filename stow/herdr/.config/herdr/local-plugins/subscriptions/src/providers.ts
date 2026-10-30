import { Clock, Effect } from 'effect'
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

export const fetchSubscriptions = (): Effect.Effect<
  ReadonlyArray<ProviderReport>
> =>
  Effect.all(
    [
      fetchCodex().pipe(Effect.catch(failed('Codex'))),
      fetchClaude().pipe(Effect.catch(failed('Claude'))),
      fetchFactory().pipe(Effect.catch(failed('Droid'))),
    ],
    { concurrency: 'unbounded' },
  )
