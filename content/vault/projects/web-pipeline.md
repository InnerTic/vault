---
title: "Web Pipeline — Firecrawl Fallback Escalation"
tags:
  - projects
  - web-pipeline
  - firecrawl
  - playwright
  - architecture
modified: 2026-06-28
---

# Web Pipeline — Firecrawl Fallback Escalation

**Core idea:** Every URL passes through a decision ladder — SearXNG → Firecrawl → Playwright Stealth → Playwright Persistent → (optional) proxy retry. Each stage only activates on failure.

## Why

Simple web fetching (curl, wget, even headless browsers) fails on JS-heavy, anti-bot sites. Firecrawl handles ~80% of sites cleanly but needs a fallback for the rest. Rather than one monolithic tool, a graduated perception stack lets each URL find its own level.

## Architecture

```
/opt/web-pipeline/            # VM root
├── router/                   # decides which tool to use
├── firecrawl/                # primary extractor
├── playwright/               # fallback engine
│   ├── stealth.js            # headless + anti-detection
│   └── persistent.js         # non-headless + stored profile
├── profiles/                 # persistent browser identities
│   └── default/              # cookies, cache, fingerprint
├── cache/                    # MD5-hashed, 10-min TTL
├── logs/                     # per-fetch .md notes + journal
├── config/
├── fetch.js                  # CLI entrypoint
├── mcp-server.js             # MCP server wrapper
└── cleanup.js                # purge old fetch notes
```

## Pipeline Flow

```
┌─────────────┐
│    URL in    │
└──────┬──────┘
       │
       ▼
┌──────────────┐
│  Firecrawl   │──✓──→ Return markdown
│  (fast path) │
└──────┬──────┘
       │ fail
       ▼
┌──────────────────┐
│ Playwright Stealth│──✓──→ Return text
│ (playwright-extra)│
│ headless: false   │
└──────┬───────────┘
       │ fail
       ▼
┌───────────────────┐
│  Persistent       │──✓──→ Return text
│  Browser Identity │
│  non-headless     │
│  stored profile   │
│  --force-dark-mode│
└───────┬──────────┘
        │ fail
        ▼
   (optional: proxy + delay)
```

### Stage 0 — Input normalization

Strip tracking params, resolve redirects (optional HEAD request), classify domain.

### Stage 1 — Firecrawl (fast path)

Try Firecrawl first for everything. Returns clean markdown/JSON. Failure triggers: timeout, empty content, bot detection page, 403/503/captcha HTML.

Failure output:
```json
{ "stage": "firecrawl", "status": "failed", "reason": "blocked|empty|timeout" }
```

### Stage 2 — Playwright Stealth (JS render)

Uses `playwright-extra` + `puppeteer-extra-plugin-stealth` to spoof headless detection. Loads page, waits for network idle, extracts DOM text.

```js
await page.goto(url, { waitUntil: "networkidle" })
await page.waitForTimeout(1500)
```

### Stage 3 — Persistent Browser Identity (C+ upgrade)

This is the "real browser persona":

```js
chromium.launchPersistentContext('./profiles/default', {
  headless: false,
  args: ['--no-sandbox', '--force-dark-mode']
})
```

- Same cookies every run
- Stable fingerprint
- Long-lived session identity
- Slow interaction timing
- Viewport consistency

Display served via Xvfb on `:99` or the VM's real X server on `:1`.

### Stage 4 — Optional escalation

If still blocked:
- **A:** Retry with 10–30s delay
- **B:** Rotate profile (`profiles/profile_1`, `profiles/profile_2`)
- **C:** Proxy injection (advanced tier)

## Failure Detection Heuristics

### Firecrawl failure

- Empty markdown
- "enable javascript" in output
- "access denied" in output
- HTML length < threshold
- Repeated boilerplate DOM

### Playwright failure

- Page title contains: `captcha`, `just a moment`, `verify you are human`
- DOM contains: `cloudflare`, `datadome`, `perimeterx`

## Caching Layer

Before ANY fetch: cache lookup → return if fresh.

```
Key: MD5(url + render_mode)
TTL: 10 minutes
```

Prevents repeated bot triggering on the same URL.

## MCP Integration

Exposed as a single MCP tool `web_fetch`:

```json
{
  "name": "web_fetch",
  "description": "Fetch a URL with automatic escalation",
  "inputSchema": {
    "url": "string",
    "mode": "auto | firecrawl | stealth | persistent",
    "raw": "boolean (return HTML instead of text)"
  }
}
```

The LLM never sees complexity. It just calls `fetch(url)`.

## Coverage Model

| Tier | Tool | Coverage | Example sites |
|------|------|----------|---------------|
| 1 | SearXNG → Firecrawl | ~80% | docs, blogs, static |
| 2 | Playwright Stealth | ~15% | SPA apps, JS portals |
| 3 | Persistent Browser | ~5% | Qidian, anti-bot sites |
| 4 | Proxy + human profile | rare | Cloudflare Turnstile |

## Current Implementation

Deployed at `/mnt/workspace/web-pipeline/`:
- Router, stealth, persistent modules all built and tested
- Xvfb for non-headless display
- Persistent profile at `profiles/default/`
- Cache with 10-min TTL
- Per-fetch `.md` logs with `[[wikilinks]]` + aggregated `journal.md`
- Cleanup of fetch notes >24h

## Roadmap

- [ ] Fix SearXNG API (403) for discovery
- [ ] Profile rotation pool
- [ ] Smart failure classifier
- [ ] Proxy layer
