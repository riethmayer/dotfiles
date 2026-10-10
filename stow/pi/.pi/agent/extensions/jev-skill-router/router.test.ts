import assert from 'node:assert/strict'
import test from 'node:test'

import {
  isLowInformationPrompt,
  promptHash,
  topProbabilities,
} from './index.ts'

test('skips only low-information acknowledgements', () => {
  assert.equal(isLowInformationPrompt('continue'), true)
  assert.equal(
    isLowInformationPrompt('please continue with the Effect rewrite'),
    false,
  )
})

test('hashes prompts without retaining their contents', () => {
  const hash = promptHash('sensitive prompt')
  assert.match(hash, /^[a-f0-9]{16}$/)
  assert.doesNotMatch(hash, /sensitive/)
})

test('keeps the three highest classifier probabilities', () => {
  assert.deepEqual(
    topProbabilities({
      effect: 0.7,
      none: 0.1,
      typescript: 0.15,
      refactor: 0.05,
    }),
    [
      ['effect', 0.7],
      ['typescript', 0.15],
      ['none', 0.1],
    ],
  )
})
