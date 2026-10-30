import { describe, expect, it } from 'vitest'
import { parseRateLimitHeaders } from './api-keys.js'

describe('parseRateLimitHeaders', () => {
  it('parses Anthropic request and token windows', () => {
    const headers = new Headers({
      'anthropic-ratelimit-requests-limit': '1000',
      'anthropic-ratelimit-requests-remaining': '999',
      'anthropic-ratelimit-requests-reset': '2026-10-30T12:03:50Z',
      'anthropic-ratelimit-input-tokens-limit': '2000000',
      'anthropic-ratelimit-input-tokens-remaining': '1900000',
      'anthropic-ratelimit-input-tokens-reset': '2026-10-30T12:03:50Z',
    })

    expect(parseRateLimitHeaders(headers)).toEqual([
      {
        name: 'Requests',
        limit: 1000,
        remaining: 999,
        resetsAt: Date.parse('2026-10-30T12:03:50Z'),
      },
      {
        name: 'Input tokens',
        limit: 2000000,
        remaining: 1900000,
        resetsAt: Date.parse('2026-10-30T12:03:50Z'),
      },
    ])
  })

  it('ignores incomplete or invalid windows', () => {
    const headers = new Headers({
      'anthropic-ratelimit-requests-limit': '1000',
      'anthropic-ratelimit-output-tokens-limit': 'invalid',
      'anthropic-ratelimit-output-tokens-remaining': '10',
    })

    expect(parseRateLimitHeaders(headers)).toEqual([])
  })
})
