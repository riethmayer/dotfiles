# Bases Functions Reference

## Table of Contents

1. [Global Functions](#global-functions)
2. [Date Functions](#date-functions)
3. [Duration Type](#duration-type)
4. [String Functions](#string-functions)
5. [Number Functions](#number-functions)
6. [List Functions](#list-functions)
7. [File Functions](#file-functions)
8. [Link & Object Functions](#link--object-functions)

## Global Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `date()` | `date(string): date` | Parse string (`YYYY-MM-DD HH:mm:ss`) |
| `duration()` | `duration(string): duration` | Parse duration string |
| `now()` | `now(): date` | Current datetime |
| `today()` | `today(): date` | Current date (00:00:00) |
| `if()` | `if(cond, true, false?)` | Conditional |
| `min()` | `min(n1, n2, ...): number` | Smallest |
| `max()` | `max(n1, n2, ...): number` | Largest |
| `number()` | `number(any): number` | Convert to number |
| `link()` | `link(path, display?): Link` | Create link |
| `list()` | `list(el): List` | Wrap in list |
| `file()` | `file(path): file` | Get file object |
| `image()` | `image(path): image` | Create image |
| `icon()` | `icon(name): icon` | Lucide icon |
| `html()` | `html(string): html` | Render HTML |
| `escapeHTML()` | `escapeHTML(string): string` | Escape HTML |

## Any Type

| Function | Description |
|----------|-------------|
| `any.isTruthy()` | Coerce to boolean |
| `any.isType(type)` | Check type |
| `any.toString()` | Convert to string |

## Date Functions

**Fields:** `.year`, `.month`, `.day`, `.hour`, `.minute`, `.second`, `.millisecond`

| Function | Description |
|----------|-------------|
| `date.date()` | Remove time portion |
| `date.format(pattern)` | Format with Moment.js pattern |
| `date.time()` | Get time as string |
| `date.relative()` | Human-readable relative time |
| `date.isEmpty()` | Always false for dates |

### Date Arithmetic

```yaml
"now() + \"1 day\""           # Tomorrow
"today() + \"7d\""            # Week from today
"now() - file.ctime"          # Returns Duration
"(now() - file.ctime).days"   # Days as number
```

Duration units: `y/year/years`, `M/month/months`, `d/day/days`, `w/week/weeks`, `h/hour/hours`, `m/minute/minutes`, `s/second/seconds`

## Duration Type

Date subtraction returns **Duration**, not a number.

**Fields:** `.days`, `.hours`, `.minutes`, `.seconds`, `.milliseconds`

**IMPORTANT:** Duration does NOT support `.round()` directly. Access a numeric field first:

```yaml
# CORRECT
"(date(due_date) - today()).days"            # Number
"(now() - file.ctime).days.round(0)"        # Rounded number

# WRONG — will error
"(now() - file.ctime).round(0)"             # Duration has no .round()
```

## String Functions

**Field:** `.length`

| Function | Description |
|----------|-------------|
| `contains(value)` | Check substring |
| `containsAll(...values)` | All substrings present |
| `containsAny(...values)` | Any substring present |
| `startsWith(query)` | Starts with |
| `endsWith(query)` | Ends with |
| `isEmpty()` | Empty or not present |
| `lower()` | To lowercase |
| `title()` | To Title Case |
| `trim()` | Remove whitespace |
| `replace(pattern, replacement)` | Replace |
| `repeat(count)` | Repeat string |
| `reverse()` | Reverse |
| `slice(start, end?)` | Substring |
| `split(separator, n?)` | Split to list |

## Number Functions

| Function | Description |
|----------|-------------|
| `abs()` | Absolute value |
| `ceil()` | Round up |
| `floor()` | Round down |
| `round(digits?)` | Round to digits |
| `toFixed(precision)` | Fixed-point string |
| `isEmpty()` | Not present |

## List Functions

**Field:** `.length`

| Function | Description |
|----------|-------------|
| `contains(value)` | Element exists |
| `containsAll(...values)` | All exist |
| `containsAny(...values)` | Any exists |
| `filter(expression)` | Filter (uses `value`, `index`) |
| `map(expression)` | Transform (uses `value`, `index`) |
| `reduce(expression, initial)` | Reduce (uses `value`, `index`, `acc`) |
| `flat()` | Flatten nested |
| `join(separator)` | Join to string |
| `reverse()` | Reverse order |
| `slice(start, end?)` | Sublist |
| `sort()` | Sort ascending |
| `unique()` | Remove duplicates |
| `isEmpty()` | No elements |

## File Functions

| Function | Description |
|----------|-------------|
| `file.asLink(display?)` | Convert to link |
| `file.hasLink(otherFile)` | Has link to file |
| `file.hasTag(...tags)` | Has any of tags |
| `file.hasProperty(name)` | Has property |
| `file.inFolder(folder)` | In folder/subfolder |

## Link & Object Functions

**Link:**
| Function | Description |
|----------|-------------|
| `link.asFile()` | Get file object |
| `link.linksTo(file)` | Links to file |

**Object:**
| Function | Description |
|----------|-------------|
| `object.isEmpty()` | No properties |
| `object.keys()` | List of keys |
| `object.values()` | List of values |

**RegExp:**
| Function | Description |
|----------|-------------|
| `regexp.matches(string)` | Test match |
