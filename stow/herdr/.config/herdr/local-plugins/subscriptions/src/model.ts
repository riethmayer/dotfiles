import { DateTime, Option } from 'effect'

export interface UsageWindow {
  readonly label: string
  readonly usedPercent: number
  readonly resetsAt?: number
}

export interface ProviderReport {
  readonly name: string
  readonly plan?: string
  readonly windows: ReadonlyArray<UsageWindow>
  readonly balance?: string
  readonly note?: string
  readonly source: string
  readonly updatedAt: number
  readonly error?: string
}

export const clampPercent = (value: number): number =>
  Math.min(100, Math.max(0, value))

export const parseTimestamp = (value: unknown): number | undefined => {
  if (typeof value !== 'string' && typeof value !== 'number') return undefined

  const numeric = typeof value === 'number' ? value : Number(value)
  const input = Number.isFinite(numeric)
    ? numeric < 10_000_000_000
      ? numeric * 1000
      : numeric
    : value
  const parsed = DateTime.make(input)

  return Option.isSome(parsed)
    ? DateTime.toEpochMillis(parsed.value)
    : undefined
}

export const titleCase = (value: string): string =>
  value
    .split(/[_-]/u)
    .filter(Boolean)
    .map((part) => part[0]?.toUpperCase() + part.slice(1))
    .join(' ')
