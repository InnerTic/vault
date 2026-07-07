---
title: "Citation & Attribution Pipeline"
tags:
  - projects
  - citation
  - attribution
  - local-ai
modified: 2026-06-26
---

# Citation & Attribution Pipeline

**Goal:** Every vault file with external provenance gets a `source:` field in frontmatter. Files ≥90% line-similar to a known repo get auto-tagged and cited.

## Why

Prompt hats, configs, scripts, and reference docs were gathered from various repos over time. No systematic source tracking exists. This project fixes that using the local AI (Qwen3.6-35B on P40).

## Pipeline

### Phase 1 — Scan uncited files

`vault-attribution.py scan` — lists all vault files missing `source:` in frontmatter. Currently **all 203 docs files** need review.

### Phase 2 — Fetch source candidates

`vault-attribution.py fetch URL` — downloads a repo file, normalizes it, stores in a local cache at `~/.local/share/vault-attribution/sources/`.

### Phase 3 — Line-by-line comparison

`vault-attribution.py compare SOURCE_FILE` — for each vault file:
1. Strip frontmatter, normalize whitespace
2. Split into lines (min 5 significant lines to compare)
3. Compute similarity: `len(set(a_lines) & set(b_lines)) / max(len(a_lines), len(b_lines))`
4. If ≥90% → flag for auto-attribution
5. If 50-89% → flag for human review

### Phase 4 — Add citations

`vault-attribution.py apply` — adds `source:` field to confirmed matches:
```yaml
source: https://github.com/owner/repo/blob/main/path/to/file
```

### Phase 5 — AI audit of remaining

`vault-attribution.py audit` — remaining uncited files get reviewed by local AI:
- Sends content + prompt asking for origin guess
- Appends `source:` guess with `# TODO: verify` suffix
- Human reviews and confirms

## Implementation

### Script

`~/.local/bin/vault-attribution.py` — single-file CLI tool.

```
Commands:
  scan                   List all vault .md files missing source:
  fetch URL              Download and cache a source file for comparison
  compare [SOURCE]       Run line-by-line comparison against cached sources
  apply                  Add source: fields to confirmed matches
  audit                  AI review of remaining uncited files
  status                 Show pipeline progress
```

### Similarity algorithm

```python
def line_similarity(a_lines: list[str], b_lines: list[str]) -> float:
    """Jaccard-like: intersection / max(len(a), len(b))."""
    a_norm = [l.strip().lower() for l in a_lines if l.strip()]
    b_norm = [l.strip().lower() for l in b_lines if l.strip()]
    if not a_norm or not b_norm:
        return 0.0
    set_a, set_b = set(a_norm), set(b_norm)
    return len(set_a & set_b) / max(len(set_a), len(set_b))
```

### AI-assisted audit (Phase 5)

For files without a source, POST to local llama-server:
```json
POST /v1/chat/completions
{
  "model": "Qwen3.6-35B...",
  "messages": [
    {"role": "system", "content": "Given vault content below, guess the external source repo or URL it was derived from. If none, say ORIGINAL."},
    {"role": "user", "content": "<file content>"}
  ],
  "max_tokens": 200,
  "temperature": 0
}
```

## Status

| Phase | Status |
|-------|--------|
| 1 — Scan | Script written |
| 2 — Fetch | TBD |
| 3 — Compare | Script written |
| 4 — Apply | TBD |
| 5 — Audit | TBD |
