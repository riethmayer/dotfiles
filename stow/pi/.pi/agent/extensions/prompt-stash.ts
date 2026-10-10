import type {
  ExtensionAPI,
  ExtensionContext,
} from '@earendil-works/pi-coding-agent'
import { Effect, Option, Schema } from 'effect'

const stateKey = Symbol.for('dotfiles.pi.prompt-stash.v1')
const statusKey = 'prompt-stash'

interface Stash {
  text: Option.Option<string>
}

const decodeText = Schema.decodeUnknownOption(Schema.String)

const storedText = (value: unknown): Option.Option<string> => {
  if (Option.isOption(value)) return Option.flatMap(value, decodeText)
  return decodeText(value)
}

const updateStatus = Effect.fnUntraced(function* (
  stash: Stash,
  ctx: ExtensionContext,
) {
  yield* Effect.sync(() => {
    ctx.ui.setStatus(
      statusKey,
      Option.isNone(stash.text)
        ? undefined
        : 'Draft stashed · send a prompt or Ctrl+S on empty input to restore',
    )
  })
})

const restore = Effect.fnUntraced(function* (
  stash: Stash,
  ctx: ExtensionContext,
) {
  if (Option.isNone(stash.text) || ctx.ui.getEditorText() !== '') return

  const text = stash.text.value
  yield* Effect.sync(() => {
    ctx.ui.setEditorText(text)
    stash.text = Option.none()
  })
  yield* updateStatus(stash, ctx)
})

export default function (pi: ExtensionAPI) {
  const memory = globalThis as typeof globalThis & {
    [stateKey]?: { text?: unknown }
  }
  const stash: Stash = { text: storedText(memory[stateKey]?.text) }
  memory[stateKey] = stash

  pi.registerShortcut('ctrl+s', {
    description: 'Stash draft; restore after the next prompt or on empty input',
    handler: (ctx) => {
      if (ctx.mode !== 'tui') return

      Effect.runSync(
        Effect.gen(function* () {
          const text = ctx.ui.getEditorText()
          if (text === '') return yield* restore(stash, ctx)
          if (!text.trim()) return

          if (Option.isSome(stash.text)) {
            return yield* Effect.sync(() => {
              ctx.ui.notify(
                'A draft is already stashed. Send this prompt, or clear the editor and press Ctrl+S to restore it.',
                'warning',
              )
            })
          }

          yield* Effect.sync(() => {
            stash.text = Option.some(text)
            ctx.ui.setEditorText('')
          })
          yield* updateStatus(stash, ctx)
        }),
      )
    },
  })

  pi.on('input', (event, ctx) => {
    if (ctx.mode !== 'tui' || event.source !== 'interactive') return
    Effect.runSync(restore(stash, ctx))
  })

  pi.on('session_start', (_event, ctx) => {
    if (ctx.mode === 'tui') Effect.runSync(updateStatus(stash, ctx))
  })
}
