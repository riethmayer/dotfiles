import { createHash, randomUUID } from 'node:crypto'
import { appendFile, mkdir } from 'node:fs/promises'
import { homedir } from 'node:os'
import { delimiter, dirname, join, resolve } from 'node:path'

import type {
  ExtensionAPI,
  ExtensionContext,
} from '@earendil-works/pi-coding-agent'
import { DateTime, Effect, Option, Schema } from 'effect'

import { loadSkillCatalog, type SkillCatalogEntry } from './catalog.ts'

const STATUS_KEY = 'jev-skill-router'
const OP_REFERENCE =
  process.env.PI_JEV_API_KEY_REF ??
  'op://machines/jev-typesafe-ai-jan-local-api-key/credential'
const SKILLS_ROOT =
  process.env.PI_SKILLS_ROOT ?? join(homedir(), 'skills', 'skills')
const EXTRA_SKILLS_ROOTS = (
  process.env.PI_SKILLS_EXTRA_ROOTS ??
  join(homedir(), '.agents', 'skills', 'effect-ts')
)
  .split(delimiter)
  .filter(Boolean)
const STATE_FILE = join(
  process.env.XDG_STATE_HOME ?? join(homedir(), '.local', 'state'),
  'pi',
  'jev-skill-router.jsonl',
)
const NONE_DESCRIPTION =
  'No skill fits. The agent should answer or act directly.'

interface RouteDecision {
  id: string
  pick: string
  confidence: number
  top3: Array<[string, number]>
  promptHash: string
  timestamp: string
}

class RouterError extends Schema.TaggedError<RouterError>()('RouterError', {
  operation: Schema.String,
  cause: Schema.Defect(),
}) {}

export function isLowInformationPrompt(prompt: string): boolean {
  const normalized = prompt.trim().toLowerCase()
  if (!normalized) return true
  if (normalized.split(/\s+/).length > 4) return false
  return /^(yes|no|ok|okay|sure|thanks|thank you|continue|go ahead|do it|proceed|yep|nope)[.!?]*$/.test(
    normalized,
  )
}

export function promptHash(prompt: string): string {
  return createHash('sha256').update(prompt).digest('hex').slice(0, 16)
}

export function topProbabilities(
  probabilities: Record<string, number>,
): Array<[string, number]> {
  return Object.entries(probabilities)
    .sort((left, right) => right[1] - left[1])
    .slice(0, 3)
}

const logEvent = Effect.fn('JevRouter.logEvent')(
  (event: Record<string, unknown>) =>
    Effect.tryPromise({
      try: async () => {
        await mkdir(dirname(STATE_FILE), { recursive: true })
        await appendFile(STATE_FILE, `${JSON.stringify(event)}\n`, 'utf8')
      },
      catch: (cause) =>
        new RouterError({ operation: 'write telemetry', cause }),
    }),
)

const setStatus = (
  ctx: ExtensionContext,
  text: string | undefined,
): Effect.Effect<void> =>
  Effect.sync(() => {
    if (ctx.mode === 'tui') ctx.ui.setStatus(STATUS_KEY, text)
  })

export default function (pi: ExtensionAPI) {
  let catalog: SkillCatalogEntry[] = []
  let catalogByPath = new Map<string, SkillCatalogEntry>()
  let latestDecision: RouteDecision | undefined
  let credentialReady = false
  let ownsCredential = false

  const ensureCredential = Effect.fnUntraced(function* () {
    if (credentialReady) return true
    if (process.env.TYPESAFE_API_KEY) {
      credentialReady = true
      return true
    }

    const result = yield* Effect.tryPromise({
      try: () => pi.exec('op', ['read', OP_REFERENCE], { timeout: 5_000 }),
      catch: (cause) =>
        new RouterError({ operation: 'read credential', cause }),
    }).pipe(Effect.option)
    if (Option.isNone(result)) return false

    const apiKey = result.value.stdout.trim()
    if (result.value.code !== 0 || !apiKey) return false

    process.env.TYPESAFE_API_KEY = apiKey
    credentialReady = true
    ownsCredential = true
    return true
  })

  const classifyPrompt = Effect.fn('JevRouter.classifyPrompt')(function* (
    prompt: string,
    ctx: ExtensionContext,
  ): Effect.fn.Return<Option.Option<RouteDecision>, RouterError> {
    if (!(yield* ensureCredential())) return Option.none()

    const jev = ctx.modelRegistry.findOfType(
      'classifier',
      'typesafe',
      'jev-latest',
    )
    if (!jev) return Option.none()

    const criteria: Record<string, string> = Object.fromEntries(
      catalog.map((skill) => [skill.name, skill.description.slice(0, 300)]),
    )
    criteria.none = NONE_DESCRIPTION

    const result = yield* Effect.tryPromise({
      try: () =>
        ctx.modelRegistry.classify(
          jev,
          {
            state: { user_prompt: prompt.slice(0, 16_000) },
            questions: {
              skill: {
                type: 'choice',
                instructions:
                  'Which agent skill should handle `user_prompt`? Pick none when no skill fits.',
                criteria,
              },
            },
          },
          { signal: AbortSignal.timeout(60_000) },
        ),
      catch: (cause) =>
        new RouterError({ operation: 'classify prompt', cause }),
    })

    const answer =
      result.stopReason === 'stop' ? result.answers.skill : undefined
    if (!answer || answer.type !== 'choice') return Option.none()

    const now = yield* DateTime.now
    return Option.some({
      id: randomUUID(),
      pick: answer.choice,
      confidence: answer.confidence,
      top3: topProbabilities(answer.probabilities),
      promptHash: promptHash(prompt),
      timestamp: DateTime.formatIso(now),
    })
  })

  const routePrompt = Effect.fn('JevRouter.routePrompt')(function* (
    prompt: string,
    ctx: ExtensionContext,
  ) {
    if (isLowInformationPrompt(prompt)) {
      return yield* setStatus(ctx, 'Jev · skipped low-information prompt')
    }

    yield* setStatus(ctx, 'Jev · routing…')
    const startedAt = yield* DateTime.now

    const decision = yield* classifyPrompt(prompt, ctx)
    if (Option.isNone(decision)) {
      return yield* setStatus(ctx, 'Jev · unavailable')
    }

    latestDecision = decision.value
    yield* setStatus(
      ctx,
      `Jev → ${decision.value.pick} ${decision.value.confidence.toFixed(2)}`,
    )

    const finishedAt = yield* DateTime.now
    yield* logEvent({
      type: 'route',
      ...decision.value,
      durationMs:
        DateTime.toEpochMillis(finishedAt) - DateTime.toEpochMillis(startedAt),
      cwd: ctx.cwd,
      sessionId: ctx.sessionManager.getSessionId(),
      catalogSize: catalog.length,
    })
  })

  const routeSafely = Effect.fnUntraced(function* (
    prompt: string,
    ctx: ExtensionContext,
  ) {
    yield* routePrompt(prompt, ctx).pipe(
      Effect.catch((error) =>
        Effect.gen(function* () {
          yield* setStatus(ctx, 'Jev · routing failed')
          const now = yield* DateTime.now
          yield* logEvent({
            type: 'route_error',
            timestamp: DateTime.formatIso(now),
            cwd: ctx.cwd,
            sessionId: ctx.sessionManager.getSessionId(),
            error: `${error.operation}: ${String(error.cause)}`,
          }).pipe(Effect.ignore)
        }),
      ),
    )
  })

  pi.on('session_start', async (_event, ctx) => {
    await Effect.runPromise(
      Effect.gen(function* () {
        const primaryCatalog = yield* loadSkillCatalog(SKILLS_ROOT)
        const extraCatalogs = yield* Effect.forEach(
          EXTRA_SKILLS_ROOTS,
          (root) => loadSkillCatalog(root).pipe(Effect.orElseSucceed(() => [])),
        )
        catalog = [...primaryCatalog, ...extraCatalogs.flat()]
        catalogByPath = new Map(
          catalog.map((skill) => [resolve(skill.path), skill]),
        )
        const ready = yield* ensureCredential()
        yield* setStatus(
          ctx,
          ready
            ? `Jev · observing ${catalog.length} skills`
            : 'Jev · credential unavailable',
        )
        if (!ready && ctx.hasUI) {
          yield* Effect.sync(() => {
            ctx.ui.notify(
              'Jev skill router could not read its 1Password credential',
              'warning',
            )
          })
        }
      }).pipe(
        Effect.catch((error) =>
          Effect.gen(function* () {
            yield* setStatus(ctx, 'Jev · startup failed')
            if (ctx.hasUI) {
              yield* Effect.sync(() => {
                ctx.ui.notify(
                  `Jev skill router failed to start: ${String(error)}`,
                  'warning',
                )
              })
            }
          }),
        ),
      ),
    )
  })

  pi.on('input', async (event, ctx) => {
    if (event.source === 'extension' || event.streamingBehavior !== undefined) {
      return { action: 'continue' }
    }
    if (event.text.trim().startsWith('/skill:')) return { action: 'continue' }

    await Effect.runPromise(routeSafely(event.text, ctx))
    return { action: 'continue' }
  })

  pi.on('tool_call', async (event, ctx) => {
    if (event.toolName !== 'read') return
    const path =
      typeof event.input.path === 'string'
        ? resolve(ctx.cwd, event.input.path)
        : undefined
    const skill = path ? catalogByPath.get(path) : undefined
    if (!skill) return

    await Effect.runPromise(
      Effect.gen(function* () {
        const now = yield* DateTime.now
        yield* logEvent({
          type: 'skill_read',
          timestamp: DateTime.formatIso(now),
          cwd: ctx.cwd,
          sessionId: ctx.sessionManager.getSessionId(),
          skill: skill.name,
          routeId: latestDecision?.id,
          recommendedSkill: latestDecision?.pick,
          recommendedConfidence: latestDecision?.confidence,
        })
      }).pipe(Effect.ignore),
    )
  })

  pi.on('session_shutdown', async () => {
    Effect.runSync(
      Effect.sync(() => {
        if (ownsCredential) delete process.env.TYPESAFE_API_KEY
      }),
    )
  })

  pi.registerCommand('jev-status', {
    description: 'Show the observe-only Jev skill router status',
    handler: async (_args, ctx) => {
      const latest = latestDecision
        ? `${latestDecision.pick} ${latestDecision.confidence.toFixed(2)}`
        : 'no decision yet'
      ctx.ui.notify(
        `Jev router: ${catalog.length} skills, ${latest}. Telemetry: ${STATE_FILE}`,
        'info',
      )
    },
  })
}
