---
title: "Web Scraping"
tags:
  - reference
  - scraping
  - web
---

# Web Scraping

Patterns and lessons for scraping Chinese web novel sites.

## Strategy

Three-tier escalation (via `/mnt/workspace/web-pipeline/`):

1. **Fetch** (static HTML) — works for simple sites
2. **Playwright Stealth** — JS-rendered content, no login
3. **Persistent Browser** — sites with cookie/redirect anti-bot (e.g. bi89.cc)

## Scraper Template

Base scraper at `/mnt/workspace/web-pipeline/bi89-scraper.js`.

### Key Parameters (env vars)

| Var | Default | Notes |
|-----|---------|-------|
| `CONCURRENCY` | 10 | Parallel pages in same browser. Start low, ramp up |
| `DELAY` | 500 | ms between batches |
| `PAUSE_EVERY` | 100 | Pause after this many chapters |
| `PAUSE_SEC` | 15 | Pause duration in seconds |

### Site Behavior

- **bi89.cc** (笔趣阁 clone): Sequential URLs `/htm/{bookId}/{n}.html`, JS cookie redirect, persistent browser required
- **zhys.tw**: Sequential IDs via `nextUrl` in page data, Playwright stealth works
- Rate limiting manifests as boilerplate-only pages (font controls + copyright text) or "Target closed" cascade failures

### Failure Handling

- `Promise.allSettled` — isolates individual page failures
- Each worker opens its own browser context (isolated cookies/session)
- Failed chapters are requeued automatically
- Checkpoint file (`.checkpoint.json`) written every batch for resume
- Boilerplate detection: `data.includes('本站所有小说为转载作品')` signals rate limit

### Concurrency Findings

| Concurrency | Delay | Pause | Result |
|-------------|-------|-------|--------|
| 2 | 2000ms | none | Too slow, ~1 ch/6s |
| 5 | 800ms | none | OK, ~2 ch/s |
| 10 | 500ms | 15s/100 | Best so far, ~3 ch/s |
| 10+ | faster | — | Cascade failures increase |

Key insight: pause every ~100 chapters prevents rate limiting. Short delays between batches are fine.

## Cleanup Pipeline

After scraping:

```
raw/         ← scraped as-is, site ID or sequential filename
clean/       ← artifacts stripped, numbered chNNN.txt
chunks/      ← tokenized segments for translation pipeline
```

Cleaning script: `scripts/01-clean-raw.js` per project.

### Known Artifacts

**笔趣阁 sites (bi89.cc):**
- Footer: `请收藏本站：https://www.bqg78.com`, `『点此报错』`, `『加入书签』`
- Nav: `上一章目录下一章`

**zhys.tw:**
- Header: `第N章 Title\n\n{book name}\n\n`
- Footer: `返回目录\n下一章\n💾\n\ndownload App…\n\n{ad line}\n\n免费下载`
- Inline text ads (3/566 files): other novel promos appended to last paragraph

## Writing a New Scraper

1. Copy `bi89-scraper.js`
2. Change: `BOOK_DIR`, `TOTAL_CHAPTERS`, URL pattern, content selectors
3. Test with `CONCURRENCY=1`, verify output
4. Ramp concurrency watching for boilerplate failures
5. Add site-specific artifact patterns to the cleaning script
