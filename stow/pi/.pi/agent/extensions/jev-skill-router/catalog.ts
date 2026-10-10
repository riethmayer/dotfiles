import { readdir, readFile } from 'node:fs/promises'
import { join } from 'node:path'

import { Effect, Schema } from 'effect'

export interface SkillCatalogEntry {
  name: string
  description: string
  path: string
}

interface SkillFrontmatter {
  name?: string
  description?: string
  disableModelInvocation: boolean
}

export class SkillCatalogError extends Schema.TaggedError<SkillCatalogError>()(
  'SkillCatalogError',
  {
    operation: Schema.String,
    path: Schema.String,
    cause: Schema.Defect(),
  },
) {}

function unquote(value: string): string {
  const trimmed = value.trim()
  const quote = trimmed[0]
  if ((quote === '"' || quote === "'") && trimmed.at(-1) === quote) {
    return trimmed.slice(1, -1)
  }
  return trimmed
}

function parseDescription(
  lines: string[],
  startIndex: number,
  rawValue: string,
): string {
  const value = rawValue.trim()
  if (!['|', '|-', '>', '>-'].includes(value)) return unquote(value)

  const parts: string[] = []
  for (let index = startIndex + 1; index < lines.length; index += 1) {
    const line = lines[index]
    if (/^[A-Za-z0-9_-]+\s*:/.test(line)) break
    parts.push(line.replace(/^\s+/, ''))
  }

  return parts
    .join(value.startsWith('>') ? ' ' : '\n')
    .replace(/\s+/g, ' ')
    .trim()
}

export function parseSkillFrontmatter(content: string): SkillFrontmatter {
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/)
  if (!match) return { disableModelInvocation: false }

  const lines = match[1].split(/\r?\n/)
  let name: string | undefined
  let description: string | undefined
  let disableModelInvocation = false

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index]
    const separator = line.indexOf(':')
    if (separator < 0) continue

    const key = line.slice(0, separator).trim()
    const value = line.slice(separator + 1)
    if (key === 'name') name = unquote(value)
    if (key === 'description')
      description = parseDescription(lines, index, value)
    if (key === 'disable-model-invocation')
      disableModelInvocation = value.trim() === 'true'
  }

  return { name, description, disableModelInvocation }
}

const findSkillFiles = Effect.fn('SkillCatalog.findSkillFiles')(function* (
  directory: string,
): Effect.fn.Return<string[], SkillCatalogError> {
  const entries = yield* Effect.tryPromise({
    try: () => readdir(directory, { withFileTypes: true }),
    catch: (cause) =>
      new SkillCatalogError({
        operation: 'read directory',
        path: directory,
        cause,
      }),
  })
  const files: string[] = []

  for (const entry of entries) {
    if (entry.name.startsWith('.')) continue
    const path = join(directory, entry.name)
    if (entry.isDirectory()) {
      files.push(...(yield* findSkillFiles(path)))
      continue
    }
    if (entry.isFile() && entry.name === 'SKILL.md') files.push(path)
  }

  return files
})

export const loadSkillCatalog = Effect.fn('SkillCatalog.load')(function* (
  root: string,
): Effect.fn.Return<SkillCatalogEntry[], SkillCatalogError> {
  const files = yield* findSkillFiles(root)
  const byName = new Map<string, SkillCatalogEntry>()

  for (const path of files.sort()) {
    const content = yield* Effect.tryPromise({
      try: () => readFile(path, 'utf8'),
      catch: (cause) =>
        new SkillCatalogError({ operation: 'read skill', path, cause }),
    })
    const frontmatter = parseSkillFrontmatter(content)
    if (
      frontmatter.disableModelInvocation ||
      !frontmatter.name ||
      !frontmatter.description
    )
      continue
    if (byName.has(frontmatter.name)) continue

    byName.set(frontmatter.name, {
      name: frontmatter.name,
      description: frontmatter.description.replace(/\s+/g, ' ').trim(),
      path,
    })
  }

  return [...byName.values()]
})
