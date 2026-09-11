import assert from 'node:assert/strict'
import { beforeEach, test } from 'node:test'
import promptStash from '../stow/pi/.pi/agent/extensions/prompt-stash.ts'

const stateKey = Symbol.for('dotfiles.pi.prompt-stash.v1')

beforeEach(() => {
  delete globalThis[stateKey]
})

function harness(mode = 'tui') {
  let text = ''
  const statuses = new Map()
  const notifications = []
  const handlers = new Map()
  const shortcuts = new Map()
  const ctx = {
    mode,
    ui: {
      getEditorText: () => text,
      setEditorText: (value) => {
        text = value
      },
      setStatus: (key, value) => statuses.set(key, value),
      notify: (...args) => notifications.push(args),
    },
  }
  // Deliberately no sendUserMessage/appendEntry: drafts must never be sent
  // or persisted by the extension.
  promptStash({
    registerShortcut: (key, options) => shortcuts.set(key, options.handler),
    on: (event, handler) => handlers.set(event, handler),
  })
  return {
    ctx,
    statuses,
    notifications,
    type: ctx.ui.setEditorText,
    text: ctx.ui.getEditorText,
    shortcut: () => shortcuts.get('ctrl+s')(ctx),
    emit: (name, event = {}) => handlers.get(name)?.(event, ctx),
    submit: (streamingBehavior) => {
      const event = { text, source: 'interactive', streamingBehavior }
      text = ''
      const result = handlers.get('input')(event, ctx)
      return { event, result }
    },
  }
}

test('Ctrl+S hides exact multiline text and restores manually on empty input', () => {
  const h = harness()
  const draft = '  unfinished 🐦 draft\n\tsecond line\n'
  h.type(draft)
  h.shortcut()
  assert.equal(h.text(), '')
  assert.match(h.statuses.get('prompt-stash'), /Draft stashed/)
  h.shortcut()
  assert.equal(h.text(), draft)
  assert.equal(h.statuses.get('prompt-stash'), undefined)
})

for (const behavior of [undefined, 'steer', 'followUp']) {
  test(`restores synchronously on ${behavior ?? 'idle'} submission, leaving the side prompt unchanged`, () => {
    const h = harness()
    h.type('original draft')
    h.shortcut()
    h.type('side question')
    const { event, result } = h.submit(behavior)
    assert.equal(result, undefined)
    assert.equal(event.text, 'side question')
    assert.equal(h.text(), 'original draft')
    assert.equal(h.statuses.get('prompt-stash'), undefined)
    h.submit()
    assert.equal(h.text(), '', 'restored draft is consumed only once')
  })
}

test('never overwrites a second draft or loses the first stash', () => {
  const h = harness()
  h.type('first')
  h.shortcut()
  h.type('second')
  h.shortcut()
  assert.equal(h.text(), 'second')
  assert.equal(h.notifications[0][1], 'warning')
  h.submit()
  assert.equal(h.text(), 'first')
})

test('preserves text typed before the input hook, including whitespace', () => {
  for (const nextText of ['already typing again', ' \n']) {
    const h = harness()
    h.type('original')
    h.shortcut()
    h.type(nextText)
    h.emit('input', { text: 'side question', source: 'interactive' })
    assert.equal(h.text(), nextText)
    h.type('')
    h.shortcut()
    assert.equal(h.text(), 'original')
  }
})

test('extension and RPC inputs do not restore the draft', () => {
  const h = harness()
  h.type('original')
  h.shortcut()
  for (const source of ['extension', 'rpc']) {
    h.emit('input', { text: 'automated prompt', source })
    assert.equal(h.text(), '')
  }
  h.shortcut()
  assert.equal(h.text(), 'original')
})

test('non-TUI contexts do not read or mutate the editor', () => {
  for (const mode of ['rpc', 'print', 'json']) {
    const h = harness(mode)
    h.ctx.ui.getEditorText = () => assert.fail('must not access the editor')
    h.shortcut()
    h.emit('input', { source: 'interactive' })
    h.emit('session_start')
    assert.equal(h.statuses.size, 0)
  }
})

test('empty and whitespace-only drafts are not stashed', () => {
  const h = harness()
  h.shortcut()
  h.type(' \n\t')
  h.shortcut()
  assert.equal(h.text(), ' \n\t')
  h.submit()
  assert.equal(h.text(), '')
})

test('expanded pasted text round-trips without truncation', () => {
  const h = harness()
  const draft = 'pasted content 🐦\n'.repeat(5000)
  h.type(draft)
  h.shortcut()
  h.type('quick question')
  h.submit()
  assert.equal(h.text(), draft)
})

test('in-memory draft survives extension reload and session replacement', () => {
  const h = harness()
  h.type('keep across reload')
  h.shortcut()
  const reloaded = harness()
  reloaded.emit('session_start', { reason: 'reload' })
  assert.match(reloaded.statuses.get('prompt-stash'), /Draft stashed/)
  const resumed = harness()
  resumed.emit('session_start', { reason: 'resume' })
  resumed.shortcut()
  assert.equal(resumed.text(), 'keep across reload')
})

test('failed editor restoration retains the stashed draft for retry', () => {
  const h = harness()
  h.type('original')
  h.shortcut()
  h.ctx.ui.setEditorText = () => {
    throw new Error('editor unavailable')
  }
  assert.throws(() => h.shortcut(), /editor unavailable/)
  h.ctx.ui.setEditorText = h.type
  h.shortcut()
  assert.equal(h.text(), 'original')
})
