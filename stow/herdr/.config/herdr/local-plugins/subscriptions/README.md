# Subscriptions

Herdr popup for account-wide Codex, Claude, and Droid limits plus configured Anthropic API-key rate limits. Every percentage is displayed as remaining allowance, with reset countdowns and local reset times.

## Data sources

- Codex: `~/.codex/auth.json` → ChatGPT's Codex usage endpoint
- Claude: the `Claude Code-credentials` macOS Keychain item → Anthropic's OAuth usage endpoint
- Droid: the read-only `~/.factory/auth.v2.loginkeychain` login with its `Factory CLI` Keychain key, falling back to `auth.v2.{file,key}` → Factory's billing limits endpoint
- Anthropic API keys: `op://` references from the plugin's private `accounts.json` → rate-limit headers from a one-token Haiku request

The plugin never stores, logs, refreshes, or writes credentials. These are private APIs used by the corresponding first-party CLIs and may change. If Droid reports HTTP 401, run `droid` once so its CLI refreshes its own login.

## API-key accounts

Copy `accounts.example.json` to the runtime config returned by `herdr plugin config-dir subscriptions`, rename it to `accounts.json`, and add one entry per key. Only 1Password references belong in this file; the plugin resolves them using the machine service account at refresh time.

Opening or refreshing the popup makes one one-token Haiku request per configured account because Anthropic only returns rate-limit headers on inference responses. A proxy can override `baseUrl`, `auth`, and `model`. Standard API keys expose short rate-limit windows, not organization spend or budget; those require an Anthropic Admin API key.

## Development

```bash
pnpm install --frozen-lockfile
pnpm check
pnpm test
pnpm build
herdr plugin link "$PWD"
```

Open it with `Ctrl-A Ctrl-L`. Inside the popup, press `r` to refresh, `q` or Escape to close, and the arrow keys to scroll.
