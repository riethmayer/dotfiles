import { createHash, randomUUID } from 'node:crypto'
import { appendFile, mkdir } from 'node:fs/promises'
import { homedir } from 'node:os'
import { dirname, join, resolve } from 'node:path'

import type { ExtensionAPI, ExtensionContext } from '@earendil-works/pi-coding-agent'

import { loadSkillCatalog, type SkillCatalogEntry } from './catalog.ts'

const STATUS_KEY = 'jev-skill-router'
const OP_REFERENCE =
  process.env.PI_JEV_API_KEY_REF ??
  'op://machines/jev-typesafe-ai-jan-local-api-key/credential'
const SKILLS_ROOT = process.env.PI_SKILLS_ROOT ?? join(homedir(), 'skills', 'skills')
const STATE_FILE = join(
  process.env.XDG_STATE_HOME ?? join(homedir(), '.local', 'state'),
  'pi',
  'jev-skill-router.jsonl',
)
const NONE_DESCRIPTION = 'No skill fits. The agent should answer or act directly.'

interface RouteDecision {
  id: string
  pick: string
  confidence: number
  top3: Array<[string, number]>
  promptHash: string
  timestamp: string
}

function isLowInformationPrompt(prompt: string): boolean {
  const normalized = prompt.trim().toLowerCase()
  if (!normalized) return true
  if (normalized.split(/\s+/).length > 4) return false
  return /^(yes|no|ok|okay|sure|thanks|thank you|continue|go ahead|do it|proceed|yep|nope)[.!?]*$/.test(
    normalized,
  )
}

function promptHash(prompt: string): string {
  return createHash('sha256').update(prompt).digest('hex').slice(0, 16)
}

function topProbabilities(probabilities: Record<string, number>): Array<[string, number]> {
  return Object.entries(probabilities)
    .sort((left, right) => right[1] - left[1])
    .slice(0, 3)
}

async function logEvent(event: Record<string, unknown>): Promise<void> {
  await mkdir(dirname(STATE_FILE), { recursive: true })
  await appendFile(STATE_FILE, `${JSON.stringify(event)}\n`, 'utf8')
}

function setStatus(ctx: ExtensionContext, text: string | undefined): void {
  if (ctx.mode === 'tui') ctx.ui.setStatus(STATUS_KEY, text)
}

export default function (pi: ExtensionAPI) {
  let catalog: SkillCatalogEntry[] = []
  let catalogByPath = new Map<string, SkillCatalogEntry>()
  let latestDecision: RouteDecision | undefined
  let credentialReady = false
  let ownsCredential = false

  async function ensureCredential(): Promise<boolean> {
    if (credentialReady) return true
    if (process.env.TYPESAFE_API_KEY) {
      credentialReady = true
      return true
    }

    const result = await pi.exec('op', ['read', OP_REFERENCE], { timeout: 5_000 })
    const apiKey = result.stdout.trim()
    if (result.code !== 0 || !apiKey) return false

    process.env.TYPESAFE_API_KEY = apiKey
    credentialReady = true
    ownsCredential = true
    return true
  }

  async function classifyPrompt(prompt: string, ctx: ExtensionContext): Promise<RouteDecision | undefined> {
    if (!(await ensureCredential())) return undefined

    const jev = ctx.modelRegistry.findOfType('classifier', 'typesafe', 'jev-latest')
    if (!jev) return undefined

    const criteria: Record<string, string> = Object.fromEntries(
      catalog.map((skill) => [skill.name, skill.description.slice(0, 300)]),
    )
    criteria.none = NONE_DESCRIPTION

    const result = await ctx.modelRegistry.classify(
      jev,
      {
        state: { user_prompt: prompt.slice(0, 16_000) },
        questions: {
          skill: {
            type: 'choice',
            instructions: 'Which agent skill should handle `user_prompt`? Pick none when no skill fits.',
            criteria,
          },
        },
      },
      { signal: AbortSignal.timeout(60_000) },
    )

    const answer = result.stopReason === 'stop' ? result.answers.skill : undefined
    if (!answer || answer.type !== 'choice') return undefined

    return {
      id: randomUUID(),
      pick: answer.choice,
      confidence: answer.confidence,
      top3: topProbabilities(answer.probabilities),
      promptHash: promptHash(prompt),
      timestamp: new Date().toISOString(),
    }
  }

  async function routePrompt(prompt: string, ctx: ExtensionContext): Promise<void> {
    if (isLowInformationPrompt(prompt)) {
      setStatus(ctx, 'Jev · skipped low-information prompt')
      return
    }

    setStatus(ctx, 'Jev · routing…')
    const startedAt = performance.now()

    try {
      const decision = await classifyPrompt(prompt, ctx)
      if (!decision) {
        setStatus(ctx, 'Jev · unavailable')
        return
      }

      latestDecision = decision
      setStatus(ctx, `Jev → ${decision.pick} ${decision.confidence.toFixed(2)}`)
      await logEvent({
        type: 'route',
        ...decision,
        durationMs: Math.round(performance.now() - startedAt),
        cwd: ctx.cwd,
        sessionId: ctx.sessionManager.getSessionId(),
        catalogSize: catalog.length,
      })
    } catch (error) {
      setStatus(ctx, 'Jev · routing failed')
      await logEvent({
        type: 'route_error',
        timestamp: new Date().toISOString(),
        cwd: ctx.cwd,
        sessionId: ctx.sessionManager.getSessionId(),
        error: error instanceof Error ? error.message : String(error),
      })
    }
  }

  pi.on('session_start', async (_event, ctx) => {
    try {
      catalog = await loadSkillCatalog(SKILLS_ROOT)
      catalogByPath = new Map(catalog.map((skill) => [resolve(skill.path), skill]))
      const ready = await ensureCredential()
      setStatus(ctx, ready ? `Jev · observing ${catalog.length} skills` : 'Jev · credential unavailable')
      if (!ready && ctx.hasUI) {
        ctx.ui.notify('Jev skill router could not read its 1Password credential', 'warning')
      }
    } catch (error) {
      setStatus(ctx, 'Jev · startup failed')
      if (ctx.hasUI) {
        ctx.ui.notify(
          `Jev skill router failed to start: ${error instanceof Error ? error.message : String(error)}`,
          'warning',
        )
      }
    }
  })

  pi.on('input', async (event, ctx) => {
    if (event.source === 'extension' || event.streamingBehavior !== undefined) {
      return { action: 'continue' }
    }
    if (event.text.trim().startsWith('/skill:')) return { action: 'continue' }

    await routePrompt(event.text, ctx)
    return { action: 'continue' }
  })

  pi.on('tool_call', async (event, ctx) => {
    if (event.toolName !== 'read') return
    const path = typeof event.input.path === 'string' ? resolve(ctx.cwd, event.input.path) : undefined
    const skill = path ? catalogByPath.get(path) : undefined
    if (!skill) return

    await logEvent({
      type: 'skill_read',
      timestamp: new Date().toISOString(),
      cwd: ctx.cwd,
      sessionId: ctx.sessionManager.getSessionId(),
      skill: skill.name,
      routeId: latestDecision?.id,
      recommendedSkill: latestDecision?.pick,
      recommendedConfidence: latestDecision?.confidence,
    })
  })

  pi.on('session_shutdown', async () => {
    if (ownsCredential) delete process.env.TYPESAFE_API_KEY
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
