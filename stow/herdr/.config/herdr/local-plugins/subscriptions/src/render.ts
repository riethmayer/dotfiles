import { DateTime, Option } from 'effect'
import type { ProviderReport, UsageWindow } from './model.js'

const ansi = {
  bold: '\u001b[1m',
  dim: '\u001b[2m',
  green: '\u001b[38;5;143m',
  yellow: '\u001b[38;5;179m',
  red: '\u001b[38;5;167m',
  reset: '\u001b[0m',
}

const pad = (value: string, width: number): string =>
  value.length >= width
    ? `${value.slice(0, Math.max(0, width - 1))}…`
    : value.padEnd(width)

const colorForRemaining = (remaining: number): string =>
  remaining <= 20 ? ansi.red : remaining <= 40 ? ansi.yellow : ansi.green

const countdown = (milliseconds: number): string => {
  const totalMinutes = Math.max(0, Math.floor(milliseconds / 60_000))
  const days = Math.floor(totalMinutes / (24 * 60))
  const hours = Math.floor((totalMinutes % (24 * 60)) / 60)
  const minutes = totalMinutes % 60
  if (days > 0) return `${days}d ${hours}h`
  if (hours > 0) return `${hours}h ${minutes}m`
  return `${minutes}m`
}

const localTime = (epochMillis: number): string => {
  const value = DateTime.make(epochMillis)
  if (Option.isNone(value)) return 'unknown'
  return DateTime.formatLocal(value.value, {
    weekday: 'short',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  })
}

const windowLine = (
  window: UsageWindow,
  now: number,
  labelWidth: number,
): string => {
  const remaining = Math.round(100 - window.usedPercent)
  const color = colorForRemaining(remaining)
  const reset = window.resetsAt
    ? `${countdown(window.resetsAt - now)} · ${localTime(window.resetsAt)}`
    : 'Reset time unavailable'
  return `  ${color}${pad(window.label, labelWidth)}  ${String(remaining).padStart(3)}% left   ${reset}${ansi.reset}`
}

export const renderLines = (
  reports: ReadonlyArray<ProviderReport>,
  now: number,
  columns: number,
): ReadonlyArray<string> => {
  const labelWidth = Math.max(18, Math.min(40, columns - 43))
  const lines: Array<string> = [
    '',
    `  ${ansi.bold}Subscriptions${ansi.reset}`,
    `  ${ansi.dim}Account-wide limits · all percentages show remaining allowance${ansi.reset}`,
    `  ${ansi.dim}${pad('Window', labelWidth)}  Remaining   Resets in · local time${ansi.reset}`,
    '',
  ]

  for (const report of reports) {
    const heading = report.plan
      ? `${report.name} · ${report.plan}`
      : report.name
    lines.push(`  ${ansi.bold}${heading}${ansi.reset}`)
    if (report.error) {
      lines.push(`  ${ansi.red}Unavailable · ${report.error}${ansi.reset}`)
    } else if (report.windows.length === 0) {
      lines.push(`  ${ansi.dim}No account limits reported${ansi.reset}`)
    } else {
      lines.push(
        ...report.windows.map((window) => windowLine(window, now, labelWidth)),
      )
    }
    if (report.note) lines.push(`  ${ansi.dim}${report.note}${ansi.reset}`)
    if (report.balance)
      lines.push(`  ${ansi.dim}${report.balance}${ansi.reset}`)
    const age = Math.max(0, Math.floor((now - report.updatedAt) / 1000))
    lines.push(
      `  ${ansi.dim}Updated ${age}s ago · ${report.source}${ansi.reset}`,
      '',
    )
  }

  return lines
}
