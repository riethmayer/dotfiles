import { resolve } from 'node:path'

import type {
  ExtensionAPI,
  ExtensionContext,
} from '@earendil-works/pi-coding-agent'
import { Effect, Option, Schema } from 'effect'

const DARK = 'dracula'
const LIGHT = 'earlybird-light'
const STATE_TYPE = 'earlybird-theme-state'

const Theme = Schema.Literals([DARK, LIGHT])
const PersistedTheme = Schema.Struct({ theme: Theme })

class ThemeSyncError extends Schema.TaggedError<ThemeSyncError>()(
  'ThemeSyncError',
  {
    cause: Schema.Defect(),
  },
) {}
const decodePersistedTheme = Schema.decodeUnknownOption(PersistedTheme)

const extensionDir = resolve(new URL('.', import.meta.url).pathname)
const SCRIPT = resolve(extensionDir, 'toggle-theme.sh')

const nextTheme = (theme: typeof Theme.Type): typeof Theme.Type =>
  theme === DARK ? LIGHT : DARK

const restoreTheme = (
  entries: ReturnType<ExtensionContext['sessionManager']['getEntries']>,
): typeof Theme.Type => {
  let theme: typeof Theme.Type = DARK

  for (const entry of entries) {
    if (entry.type !== 'custom' || entry.customType !== STATE_TYPE) continue
    const persisted = decodePersistedTheme(entry.data)
    if (Option.isSome(persisted)) theme = persisted.value.theme
  }

  return theme
}

export default function (pi: ExtensionAPI) {
  let current: typeof Theme.Type = DARK

  const toggle = Effect.fnUntraced(function* (ctx: ExtensionContext) {
    const previous = current
    current = nextTheme(current)
    const mode = current === DARK ? 'dark' : 'light'

    const result = yield* Effect.sync(() => ctx.ui.setTheme(current))
    if (!result.success) {
      const names = ctx.ui
        .getAllThemes()
        .map((theme) => theme.name)
        .join(', ')
      current = previous
      return yield* Effect.sync(() => {
        ctx.ui.notify(
          `Theme "${nextTheme(previous)}" not found. Available: ${names}`,
          'error',
        )
      })
    }

    yield* Effect.tryPromise({
      try: () => pi.exec('bash', [SCRIPT, mode], { timeout: 5_000 }),
      catch: (cause) => new ThemeSyncError({ cause }),
    }).pipe(Effect.ignore)

    yield* Effect.sync(() => {
      pi.appendEntry(STATE_TYPE, { theme: current })
      ctx.ui.notify(current === DARK ? '🌙 Dark' : '☀️ Light', 'info')
    })
  })

  pi.on('session_start', (_event, ctx) => {
    current = restoreTheme(ctx.sessionManager.getEntries())
    ctx.ui.setTheme(current)
  })

  pi.registerShortcut('ctrl+shift+t', {
    description: 'Toggle Earlybird dark/light theme (pi + Ghostty + tmux)',
    handler: (ctx) => Effect.runPromise(toggle(ctx)),
  })

  pi.registerCommand('theme-toggle', {
    description: 'Toggle between Earlybird dark and light themes',
    handler: (_args, ctx) => Effect.runPromise(toggle(ctx)),
  })
}
