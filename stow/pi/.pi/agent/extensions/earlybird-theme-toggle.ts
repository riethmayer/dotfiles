/**
 * Toggle between Earlybird dark and light themes with Ctrl+Shift+T.
 *
 * Switches in lockstep:
 *   - pi:      earlybird-dark  ↔  earlybird-light
 *   - Ghostty: Catppuccin Mocha ↔ Catppuccin Latte  (OSC 7777 → pane tty)
 *   - tmux:    catppuccin mocha ↔ catppuccin latte   (plugin re-run)
 *
 * Ghostty delivery: pi.exec() subprocesses have no /dev/tty, but we
 * can write to the specific pty device (/dev/ttysNNN) that pi owns.
 * The script gets the pane tty from tmux and writes the DCS passthrough
 * escape sequence directly to it.
 *
 * Persists preference across session restarts.
 */

import { resolve } from 'node:path'
import type { ExtensionAPI, ExtensionContext } from '@mariozechner/pi-coding-agent'

const DARK = 'dracula'
const LIGHT = 'earlybird-light'
const STATE_TYPE = 'earlybird-theme-state'

const extensionDir = resolve(new URL('.', import.meta.url).pathname)
const SCRIPT = resolve(extensionDir, 'toggle-theme.sh')

export default function (pi: ExtensionAPI) {
  let current: string = DARK

  async function toggle(ctx: ExtensionContext) {
    current = current === DARK ? LIGHT : DARK
    const mode = current === DARK ? 'dark' : 'light'

    // 1. Pi theme
    const result = ctx.ui.setTheme(current)
    if (!result.success) {
      const names = ctx.ui.getAllThemes().map(t => t.name).join(', ')
      ctx.ui.notify(`Theme "${current}" not found. Available: ${names}`, 'error')
      current = current === DARK ? LIGHT : DARK
      return
    }

    // 2. Ghostty (config + OSC 7777 via pane tty) + tmux (catppuccin)
    try {
      await pi.exec('bash', [SCRIPT, mode], { timeout: 5000 })
    } catch { /* non-fatal */ }

    // 3. Persist in session
    pi.appendEntry(STATE_TYPE, { theme: current })
    ctx.ui.notify(
      current === DARK ? '🌙 Dark' : '☀️ Light',
      'info',
    )
  }

  pi.on('session_start', async (_event, ctx) => {
    for (const entry of ctx.sessionManager.getEntries()) {
      if (entry.type === 'custom' && entry.customType === STATE_TYPE) {
        current = (entry as any).data?.theme === LIGHT ? LIGHT : DARK
      }
    }
    ctx.ui.setTheme(current)
  })

  pi.registerShortcut('ctrl+shift+t', {
    description: 'Toggle Earlybird dark/light theme (pi + Ghostty + tmux)',
    handler: toggle,
  })

  pi.registerCommand('theme-toggle', {
    description: 'Toggle between Earlybird dark and light themes',
    handler: async (_args, ctx) => toggle(ctx),
  })
}
