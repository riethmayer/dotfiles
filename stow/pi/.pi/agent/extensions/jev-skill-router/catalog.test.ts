import assert from 'node:assert/strict'
import { mkdtemp, mkdir, rm, writeFile } from 'node:fs/promises'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import test from 'node:test'

import { Effect } from 'effect'

import { loadSkillCatalog, parseSkillFrontmatter } from './catalog.ts'

test('parses inline frontmatter', () => {
  assert.deepEqual(
    parseSkillFrontmatter(`---
name: review
description: Review changed code. Use for PR reviews.
---
Body
`),
    {
      name: 'review',
      description: 'Review changed code. Use for PR reviews.',
      disableModelInvocation: false,
    },
  )
})

test('parses folded descriptions', () => {
  assert.deepEqual(
    parseSkillFrontmatter(`---
name: review
description: >-
  Review changed code.
  Use for PR reviews.
license: MIT
---
`),
    {
      name: 'review',
      description: 'Review changed code. Use for PR reviews.',
      disableModelInvocation: false,
    },
  )
})

test('marks user-invoked skills', () => {
  assert.equal(
    parseSkillFrontmatter(`---
name: handoff
description: Create a handoff.
disable-model-invocation: true
---
`).disableModelInvocation,
    true,
  )
})

test('loads model-invoked skills and excludes explicit-only skills', async () => {
  const root = await mkdtemp(join(tmpdir(), 'pi-skill-catalog-'))
  const visible = join(root, 'visible')
  const hidden = join(root, 'hidden')

  try {
    await mkdir(visible)
    await mkdir(hidden)
    await writeFile(
      join(visible, 'SKILL.md'),
      `---
name: visible
description: Visible skill.
---
`,
    )
    await writeFile(
      join(hidden, 'SKILL.md'),
      `---
name: hidden
description: Hidden skill.
disable-model-invocation: true
---
`,
    )

    const catalog = await Effect.runPromise(loadSkillCatalog(root))
    assert.deepEqual(
      catalog.map((skill) => skill.name),
      ['visible'],
    )
  } finally {
    await rm(root, { recursive: true, force: true })
  }
})
