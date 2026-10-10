import assert from 'node:assert/strict'
import test from 'node:test'

import type {
  ExtensionAPI,
  ExtensionContext,
} from '@earendil-works/pi-coding-agent'

import themeToggle from '../earlybird-theme-toggle.ts'

test('restores the persisted theme and toggles all theme targets', async () => {
  const themes: string[] = []
  const executions: Array<{ command: string; args: string[] }> = []
  const persisted: unknown[] = []
  let sessionStart:
    ((event: unknown, ctx: ExtensionContext) => unknown) | undefined
  let command: ((args: string, ctx: ExtensionContext) => unknown) | undefined

  const api = {
    on: (event: string, handler: unknown) => {
      if (event === 'session_start') {
        sessionStart = handler as typeof sessionStart
      }
    },
    registerShortcut: () => undefined,
    registerCommand: (
      _name: string,
      config: { handler: (args: string, ctx: ExtensionContext) => unknown },
    ) => {
      command = config.handler
    },
    exec: async (executable: string, args: string[]) => {
      executions.push({ command: executable, args })
      return { code: 0, stdout: '', stderr: '', killed: false }
    },
    appendEntry: (_type: string, data: unknown) => {
      persisted.push(data)
    },
  } as unknown as ExtensionAPI

  const context = {
    ui: {
      setTheme: (theme: string) => {
        themes.push(theme)
        return { success: true }
      },
      getAllThemes: () => [],
      notify: () => undefined,
    },
    sessionManager: {
      getEntries: () => [
        {
          type: 'custom',
          customType: 'earlybird-theme-state',
          data: { theme: 'earlybird-light' },
        },
      ],
    },
  } as unknown as ExtensionContext

  themeToggle(api)
  assert.ok(sessionStart)
  assert.ok(command)

  sessionStart({}, context)
  await command('', context)

  assert.deepEqual(themes, ['earlybird-light', 'dracula'])
  assert.equal(executions.length, 1)
  assert.equal(executions[0].command, 'bash')
  assert.equal(executions[0].args.at(-1), 'dark')
  assert.deepEqual(persisted, [{ theme: 'dracula' }])
})
