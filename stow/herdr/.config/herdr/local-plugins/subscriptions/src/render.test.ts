import { describe, expect, it } from 'vitest'
import { renderLines } from './render.js'

describe('subscription rendering', () => {
  it('shows remaining allowance rather than usage', () => {
    const lines = renderLines(
      [
        {
          name: 'Codex',
          plan: 'Pro',
          windows: [
            { label: '7 days', usedPercent: 39, resetsAt: 1_700_086_400_000 },
          ],
          source: 'test',
          updatedAt: 1_700_000_000_000,
        },
      ],
      1_700_000_000_000,
      100,
    ).join('\n')

    expect(lines).toContain('61% left')
    expect(lines).toContain('Codex · Pro')
  })
})
