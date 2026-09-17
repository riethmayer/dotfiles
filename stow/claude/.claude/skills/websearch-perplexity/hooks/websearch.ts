// WebSearch → Perplexity. Answers each WebSearch call with `pplx search web`
// in WebSearch's own result shape. Any failure logs a warning and falls through
// to next(e), so the native search runs instead. Key: PERPLEXITY_API_KEY, else
// `op read` through the machine's 1Password service account (dotfiles ADR-010),
// once per session. PPLX_WEBSEARCH=0 turns it off.
import type { Register } from "claude-code";

type Hit = { url: string; title: string; snippet?: string; summary?: string };

const LIMIT = 8;
const SNIPPET_CHARS = 700;
const KEY_REF = "op://machines/Perplexity API Key/credential";
const TOKEN_KEYCHAIN_SERVICE = "op-service-account-token";

let apiKey: string | undefined;

export const register: Register = (on) => {
  on("tool.call", { tool: "WebSearch" }, async ($, e, next) => {
    if ((await $.env.get("PPLX_WEBSEARCH")) === "0") return next(e);
    const fallback = (reason: string) => {
      $.ui.log(`⚠ websearch-perplexity: ${reason}; using Claude's WebSearch`);
      return next(e);
    };

    const home = (await $.env.get("HOME")) ?? "";
    apiKey ??= (await $.env.get("PERPLEXITY_API_KEY")) || undefined;
    if (!apiKey) {
      let token = await $.env.get("OP_SERVICE_ACCOUNT_TOKEN");
      if (!token) {
        const kc = await $.process
          .run(["security", "find-generic-password", "-s", TOKEN_KEYCHAIN_SERVICE, "-w"])
          .catch(() => undefined);
        if (kc?.exitCode === 0) token = kc.stdout.trim();
      }
      if (!token) return fallback(`no 1Password service account token (Keychain ${TOKEN_KEYCHAIN_SERVICE})`);
      const read = await $.process
        .run(["op", "read", KEY_REF], { env: { OP_SERVICE_ACCOUNT_TOKEN: token }, timeoutMs: 15_000 })
        .catch(() => undefined);
      if (read?.exitCode !== 0) return fallback(`no Perplexity key: op read ${KEY_REF} failed ${read?.stderr.trim().slice(0, 160) ?? ""}`);
      apiKey = read.stdout.trim();
    }
    if (!apiKey) return fallback("no Perplexity key: op read returned nothing");

    const argv = [`${home}/.local/bin/pplx`, "search", "web", e.query, "-n", String(LIMIT), "--max-tokens-per-page", "400"];
    if (e.allowed_domains?.length) argv.push("--domains", e.allowed_domains.join(","));
    if (e.blocked_domains?.length) argv.push("--excluded-domains", e.blocked_domains.join(","));

    const started = Date.now();
    const run = await $.process
      .run(argv, { env: { PERPLEXITY_API_KEY: apiKey }, timeoutMs: 45_000 })
      .catch(() => undefined);
    if (!run) return fallback("pplx did not run or timed out");
    if (run.exitCode !== 0) return fallback(`pplx failed: ${run.stderr.trim().slice(0, 200)}`);

    let hits: Hit[];
    try {
      hits = (JSON.parse(run.stdout) as { hits?: Hit[] }).hits ?? [];
    } catch {
      return fallback("pplx returned unreadable JSON");
    }
    if (hits.length === 0) return fallback("Perplexity returned no hits");

    const digest = hits
      .map((h) => {
        const text = (h.snippet ?? h.summary ?? "").replace(/\s+/g, " ").slice(0, SNIPPET_CHARS);
        return `- [${h.title}](${h.url})\n  ${text}`;
      })
      .join("\n");

    return {
      result: {
        query: e.query,
        results: [
          { tool_use_id: "perplexity", content: hits.map((h) => ({ title: h.title, url: h.url })) },
          `Excerpts:\n${digest}`,
        ],
        durationSeconds: (Date.now() - started) / 1000,
        searchCount: 1,
      },
      context: ["These WebSearch results came from Perplexity. Cite sources as markdown links."],
    };
  });
};
