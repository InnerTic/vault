---
type: work-entry
id: 20260714-002
status: completed
confidence: high
time_spent: 1.5h
projects:
  - "[[Knowledge Engine]]"
  - "[[SQLite]]"
  - "[[Translation Pipeline]]"
daily:
  - "[[2026-07-14]]"
systems:
  - "[[SQLite]]"
scripts:
  - ~/knowledge/bin/knowledge-index
  - ~/knowledge/bin/knowledge
files:
  - /home/ken/knowledge/schema.sql
  - /home/ken/knowledge/bin/knowledge-index
  - /home/ken/knowledge/bin/knowledge
  - /home/ken/knowledge/db/knowledge.db
created_pages:
  - "[[20260714-002-Knowledge-Engine-Schema-Indexer]]"
updated_pages:
  - "[[2026-07-14]]"
tags:
  - knowledge-engine
  - sqlite
  - indexer
  - schema
modified: 2026-07-14
---

# 20260714-002 — Knowledge Engine Schema + Indexer

Date: 2026-07-14

## Goal

Design the SQLite schema for the knowledge engine and build the indexer that populates it from Markdown files.

## Architecture

**Markdown is canonical. SQLite is derived.**

If you delete the database:

```
rm knowledge.db
```

Run `knowledge index full` and it comes back. This is the key design property.

```
Markdown
    │
    ├── Human edits
    ├── AI edits
    └── Git history
         │
         ▼
     Indexer
         │
         ├── SQLite
         ├── Embeddings
         └── Search index
```

SQLite is a cache. The Markdown files are the source of truth.

## Schema v2

### Tables

| Table | Purpose |
|-------|---------|
| `files` | Every markdown file: path, title, tags, word count, checksum |
| `entities` | Stable identity: CHR-0001, LOC-0003, MAG-0015, etc. |
| `aliases` | Alternative names: multi-language, primary flag |
| `relationships` | Entity connections: uses, ally_of, enemy_of, located_in |
| `appearances` | Where entities appear: chapter, paragraph, context |
| `glossary` | Translation terms: raw, translated, approved flag |
| `embeddings` | Vector embeddings: entity/file, model, dimensions |
| `wikilinks` | Extracted [[wikilinks]]: source → target resolution |
| `build_log` | Indexer run tracking |

### ID Scheme

Entities use stable IDs prefixed by type:

- `CHR-NNNN` — characters
- `LOC-NNNN` — locations
- `MAG-NNNN` — spells/abilities
- `ORG-NNNN` — organizations
- `EVT-NNNN` — events
- `ITEM-NNNN` — items
- `TERM-NNNN` — glossary terms

The Markdown can still say `[[Bell]]` because that's what humans want to read. But SQLite indexes by `CHR-0001`.

## Indexer

`knowledge-index` scans the vault and:

1. Parses YAML frontmatter (title, tags, created, modified)
2. Counts words and characters
3. Computes SHA256 checksum for change detection
4. Extracts `[[wikilinks]]` from content
5. Writes everything to SQLite in batched SQL transactions

### Design Decisions

- **Bash, not compiled**: Keeps it readable and modifiable. Performance is fine for 276 files (~2 minutes).
- **Batch SQL**: Writes to a temp `.sql` file, flushes every 100 files. Avoids per-file sqlite3 overhead.
- **`set -euo pipefail`**: Catches errors early. Fixed several `grep` exit code issues.
- **Process substitution**: `find ... | while read` creates subshells that lose variable state. Used `while read ... done < <(find ...)` instead.

## Results

```
Files:     276
Wikilinks: 631
Words:     107,605
DB size:   328K
```

### Most Linked Pages

| Links | Page |
|-------|------|
| 8 | AGENTS |
| 8 | Dotfiles |
| 7 | Meta Script Project |
| 7 | Translation Pipeline |
| 6 | Quartz |

### Top Files by Word Count

| Words | Path |
|-------|------|
| 3,508 | vault/projects/tmux-agent-interface/tmux-unified.md |
| 3,241 | vault/projects/tmux-agent-interface/tmux-guide-v4.md |
| 2,369 | vault/projects/tmux-agent-interface/tmux-research.md |
| 2,252 | vault/projects/tmux-agent-interface/tmux-research-v3.md |
| 1,982 | vault/projects/translation-pipeline/roles/INDEX.md |

## CLI Commands

```bash
knowledge index [full]   # Index vault into SQLite
knowledge sync           # Index + rsync to Quartz
knowledge build          # Quartz build + Caddy reload
knowledge publish        # index + sync + build
knowledge status         # Show everything
```

## Next Steps

- Entity extraction from translation canon files (characters.md, relationship-map.md)
- Embedding pipeline via llama-server on port 8081
- REST API for translation packet assembly
- File watcher for auto-reindex

## See Also

- [[20260714-001-LXC310-Knowledge-Engine-Setup]]
- [[Knowledge Engine]]
- [[Translation Pipeline]]
- [[SQLite]]
