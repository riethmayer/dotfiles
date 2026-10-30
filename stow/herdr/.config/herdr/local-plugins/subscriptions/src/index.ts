import { Clock, Effect } from 'effect'
import type { ProviderReport } from './model.js'
import { fetchSubscriptions } from './providers.js'
import { renderLines } from './render.js'

type Input = 'down' | 'refresh' | 'resize' | 'up' | 'quit' | 'other'

interface State {
  readonly reports: ReadonlyArray<ProviderReport>
  readonly offset: number
}

const draw = Effect.fnUntraced(function* (state: State, refreshing = false) {
  const now = yield* Clock.currentTimeMillis
  const rows = Math.max(6, process.stdout.rows ?? 24)
  const columns = Math.max(50, process.stdout.columns ?? 100)
  const lines = renderLines(state.reports, now, columns)
  const viewport = Math.max(1, rows - 2)
  const maxOffset = Math.max(0, lines.length - viewport)
  const offset = Math.min(state.offset, maxOffset)
  const visible = lines.slice(offset, offset + viewport)

  process.stdout.write('\u001b[2J\u001b[H')
  process.stdout.write(visible.join('\r\n'))
  const footer = refreshing
    ? 'Refreshing…'
    : 'r Refresh · q / Esc Close · ↑ / ↓ Scroll'
  process.stdout.write(`\u001b[${rows};1H\u001b[2m${footer}\u001b[0m`)
  return offset
})

const classify = (chunk: Buffer): Input => {
  const text = chunk.toString('utf8')
  if (text === 'q' || text === '\u001b' || text === '\u0003') return 'quit'
  if (text === 'r' || text === 'R') return 'refresh'
  if (text === '\u001b[A' || text === 'k') return 'up'
  if (text === '\u001b[B' || text === 'j') return 'down'
  return 'other'
}

const nextInput: Effect.Effect<Input> = Effect.callback((resume) => {
  const onData = (chunk: Buffer) => finish(classify(chunk))
  const onResize = () => finish('resize')
  const finish = (input: Input) => {
    process.stdin.off('data', onData)
    process.stdout.off('resize', onResize)
    resume(Effect.succeed(input))
  }

  process.stdin.once('data', onData)
  process.stdout.once('resize', onResize)

  return Effect.sync(() => {
    process.stdin.off('data', onData)
    process.stdout.off('resize', onResize)
  })
})

const runUi = Effect.gen(function* () {
  let state: State = { reports: [], offset: 0 }
  yield* draw(state, true)
  state = { reports: yield* fetchSubscriptions(), offset: 0 }
  state = { ...state, offset: yield* draw(state) }

  while (true) {
    const input = yield* nextInput
    if (input === 'quit') return
    if (input === 'refresh') {
      state = { ...state, offset: yield* draw(state, true) }
      state = { reports: yield* fetchSubscriptions(), offset: state.offset }
    } else if (input === 'up') {
      state = { ...state, offset: Math.max(0, state.offset - 1) }
    } else if (input === 'down') {
      state = { ...state, offset: state.offset + 1 }
    }
    state = { ...state, offset: yield* draw(state) }
  }
})

const program = Effect.acquireUseRelease(
  Effect.sync(() => {
    process.stdin.setRawMode?.(true)
    process.stdin.resume()
    process.stdout.write('\u001b[?1049h\u001b[?25l')
  }),
  () => runUi,
  () =>
    Effect.sync(() => {
      process.stdin.setRawMode?.(false)
      process.stdin.pause()
      process.stdout.write('\u001b[?25h\u001b[?1049l')
    }),
)

Effect.runPromise(program).catch((error: unknown) => {
  process.stderr.write(`Subscriptions failed: ${String(error)}\n`)
  process.exitCode = 1
})
