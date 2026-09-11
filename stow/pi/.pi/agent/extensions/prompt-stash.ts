import type {
  ExtensionAPI,
  ExtensionContext,
} from '@earendil-works/pi-coding-agent'

const stateKey = Symbol.for('dotfiles.pi.prompt-stash.v1')
const statusKey = 'prompt-stash'
type Stash = { text?: string }

export default function (pi: ExtensionAPI) {
  // Pi recreates extension factories on reload/session switches. Keep drafts
  // process-local without writing unsent text into session history or files.
  const memory = globalThis as typeof globalThis & { [stateKey]?: Stash }
  const stash = (memory[stateKey] ??= {})

  function updateStatus(ctx: ExtensionContext) {
    ctx.ui.setStatus(
      statusKey,
      stash.text === undefined
        ? undefined
        : 'Draft stashed · send a prompt or Ctrl+S on empty input to restore',
    )
  }

  function restore(ctx: ExtensionContext) {
    if (stash.text === undefined || ctx.ui.getEditorText() !== '') return
    ctx.ui.setEditorText(stash.text)
    delete stash.text
    updateStatus(ctx)
  }

  pi.registerShortcut('ctrl+s', {
    description: 'Stash draft; restore after the next prompt or on empty input',
    handler: (ctx) => {
      if (ctx.mode !== 'tui') return
      const text = ctx.ui.getEditorText()
      if (text === '') {
        restore(ctx)
        return
      }
      if (!text.trim()) return
      if (stash.text !== undefined) {
        ctx.ui.notify(
          'A draft is already stashed. Send this prompt, or clear the editor and press Ctrl+S to restore it.',
          'warning',
        )
        return
      }
      stash.text = text
      ctx.ui.setEditorText('')
      updateStatus(ctx)
    },
  })

  pi.on('input', (event, ctx) => {
    if (ctx.mode !== 'tui' || event.source !== 'interactive') return
    // Pi clears the editor before this hook, for both idle and queued input.
    // Restore synchronously: do not wait for an agent response or submit it.
    restore(ctx)
  })

  pi.on('session_start', (_event, ctx) => {
    if (ctx.mode === 'tui') updateStatus(ctx)
  })
}
