import { readdir, readFile } from 'node:fs/promises'
import { join } from 'node:path'

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

function unquote(value: string): string {
  const trimmed = value.trim()
  const quote = trimmed[0]
  if ((quote === '"' || quote === "'") && trimmed.at(-1) === quote) {
    return trimmed.slice(1, -1)
  }
  return trimmed
}

function parseDescription(lines: string[], startIndex: number, rawValue: string): string {
  const value = rawValue.trim()
  if (!['|', '|-', '>', '>-'].includes(value)) return unquote(value)

  const parts: string[] = []
  for (let index = startIndex + 1; index < lines.length; index += 1) {
    const line = lines[index]
    if (/^[A-Za-z0-9_-]+\s*:/.test(line)) break
    parts.push(line.replace(/^\s+/, ''))
  }

  return parts.join(value.startsWith('>') ? ' ' : '\n').replace(/\s+/g, ' ').trim()
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
    if (key === 'description') description = parseDescription(lines, index, value)
    if (key === 'disable-model-invocation') disableModelInvocation = value.trim() === 'true'
  }

  return { name, description, disableModelInvocation }
}

async function findSkillFiles(directory: string): Promise<string[]> {
  const entries = await readdir(directory, { withFileTypes: true })
  const files: string[] = []

  for (const entry of entries) {
    if (entry.name.startsWith('.')) continue
    const path = join(directory, entry.name)
    if (entry.isDirectory()) {
      files.push(...(await findSkillFiles(path)))
      continue
    }
    if (entry.isFile() && entry.name === 'SKILL.md') files.push(path)
  }

  return files
}

export async function loadSkillCatalog(root: string): Promise<SkillCatalogEntry[]> {
  const files = await findSkillFiles(root)
  const byName = new Map<string, SkillCatalogEntry>()

  for (const path of files.sort()) {
    const frontmatter = parseSkillFrontmatter(await readFile(path, 'utf8'))
    if (frontmatter.disableModelInvocation || !frontmatter.name || !frontmatter.description) continue
    if (byName.has(frontmatter.name)) continue

    byName.set(frontmatter.name, {
      name: frontmatter.name,
      description: frontmatter.description.replace(/\s+/g, ' ').trim(),
      path,
    })
  }

  return [...byName.values()]
}
