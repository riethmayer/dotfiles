import { describe, expect, it } from 'vitest'
import { clampPercent, parseTimestamp, titleCase } from './model.js'

describe('subscription model', () => {
  it('clamps percentages to an allowance range', () => {
    expect(clampPercent(-1)).toBe(0)
    expect(clampPercent(42.5)).toBe(42.5)
    expect(clampPercent(101)).toBe(100)
  })

  it('accepts timestamps in seconds, milliseconds, and ISO format', () => {
    expect(parseTimestamp(1_700_000_000)).toBe(1_700_000_000_000)
    expect(parseTimestamp(1_700_000_000_000)).toBe(1_700_000_000_000)
    expect(parseTimestamp('2024-01-01T00:00:00Z')).toBe(1_704_067_200_000)
  })

  it('formats provider plan identifiers', () => {
    expect(titleCase('default_claude_max_20x')).toBe('Default Claude Max 20x')
  })
})
