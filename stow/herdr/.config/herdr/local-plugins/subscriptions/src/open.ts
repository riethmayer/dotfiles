import { execFile } from 'node:child_process'
import { promisify } from 'node:util'
import { Effect } from 'effect'

const executeFile = promisify(execFile)
const herdr = process.env.HERDR_BIN_PATH ?? 'herdr'

const program = Effect.tryPromise({
  try: () =>
    executeFile(herdr, [
      'plugin',
      'pane',
      'open',
      '--plugin',
      'subscriptions',
      '--entrypoint',
      'overview',
    ]),
  catch: (cause) => new Error(`Could not open subscriptions: ${String(cause)}`),
})

Effect.runPromise(program).catch((error: unknown) => {
  process.stderr.write(`${String(error)}\n`)
  process.exitCode = 1
})
