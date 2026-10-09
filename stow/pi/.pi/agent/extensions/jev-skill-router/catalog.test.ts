import assert from 'node:assert/strict'
import test from 'node:test'

import { parseSkillFrontmatter } from './catalog.ts'

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
