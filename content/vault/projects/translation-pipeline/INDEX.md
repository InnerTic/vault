---
title: "Translation Pipeline"
tags:
  - projects
modified: 2026-07-10
---

# Translation Pipeline v2.1

**Active project:** `/mnt/workspace/Projects/translation/Wizard: Starting With Synthesized Gems`

A production workflow for translating Chinese web novels while preserving character continuity, terminology, and literary style.

## Design Philosophy

- **Small models** perform extraction and assembly.
- **Large models** perform reasoning and translation.
- **One context document** per chapter — no source-hunting.

## GPU Layout

| GPU | Roles | Capacity |
|-----|-------|----------|
| **RTX 3060** (CUDA0, 12GB) | Glossary, Context Assembly | Models ≤~9GB file |
| **Tesla P40** (CUDA1, 24GB) | Parser, Translate, Rewrite | Models up to ~20GB |

## Pipeline Phases

| # | Phase | Script | Model | GPU | Port |
|---|-------|--------|-------|-----|------|
| 00 | Parse | `00-parser.js` | Big | P40 | 8080 |
| 01 | Glossary | `01-glossary.py` | Small | 3060 | 8081 |
| 02 | Context | `02-context.py`* | Small | 3060 | 8081 |
| 03 | Translate | `03-translate.py` | Big | P40 | 8083 |
| 05 | Rewrite | `05-rewrite.py` | Big | P40 | 8080 |

\* Proposed replacement for current `02-briefer.py`

## Key Decisions

- [[design/context-packet|Context Packet Architecture]] — One document per chapter for translator
- [[design/glossary-architecture|Glossary Architecture]] — Candidate → Approved → Consumed
- [[design/translation-memory|Translation Memory]] — Cross-chapter term consistency

## Design Smells Found

1. **The Briefer Orphan** — Phase 2 generates rich narrative context that nothing downstream reads. Only fix: promote to context assembler.
2. **环 → Ring** — LLM defaulted to literal "Ring" for all rank terms. Fixed via glossary + regex safety net.

## Next Steps

- [ ] Build `02-context.py` to assemble translation packets from parser + glossary + light narrative
- [ ] Update `03-translate.py` to read `canon/context/` instead of separate sources
- [ ] Update `05-rewrite.py` to also consume context packet
- [ ] Re-run translate on affected chapters now that 环 glossary is in place
