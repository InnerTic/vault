---
title: "Translation Pipeline — Operations"
tags:
  - projects
  - translation-pipeline
modified: 2026-07-19
---

# Translation Pipeline — Operations Guide

## Location

**Root:** `/media/workspace/Projects/translation/`
**Scripts:** `/media/workspace/Projects/translation/scripts/`
**Orchestrator:** `/media/workspace/Projects/translation/pipe.sh`

## Commands

```
./pipe.sh init <book_dir>              Set up book directory structure
./pipe.sh extract <book_dir>           Extract EPUBs → text
./pipe.sh clean <book_dir>             Remove HTML artifacts
./pipe.sh chunk <book_dir>             Chunk for 4096 context (~12K chars)
./pipe.sh verify <book_dir>            Artifact + drift checks
./pipe.sh prep <book_dir>              Full pre-processing (all above)

./pipe.sh pipe <book_dir> <chunk>      Run translation pipeline on one chunk
./pipe.sh pipe-all <book_dir>          Run translation pipeline on all chunks

./pipe.sh combine <book_dir> [prefix]  Assemble approved chunks into chapters
./pipe.sh rewrite <book_dir> <file>    Rewrite one chapter
./pipe.sh rewrite-all <book_dir>       Rewrite all chapters

./pipe.sh all <book_dir>               Full pipeline from scratch
```

## Book Directory Structure

```
<book>/
├── pipe.d/            Per-book overrides (see [[#.d Override System]])
├── raw/               Original EPUB files
├── original/          Extracted text files
├── cleaned/           Artifact-free text
├── chunks/            Chunked text (~12K chars / ~4096 tokens)
├── work/              Pipeline working files (auto-generated)
└── output/            Final approved output
```

## Pipeline Flow

```
Pre-processing:
  [1] Extract — unzip EPUB, strip HTML tags → plain text files
  [2] Clean — remove entities, CSS remnants, normalize whitespace
  [3] Chunk — split into ~12K char chunks (fits 4096 token context)
  [4] Verify — check for HTML artifacts, verify no drift from original

Per-Chunk Translation (pipe.sh):
  [5] Glossary Candidate — extract new terms, titles, locations
  [6] Briefer — scene analysis, character presence, ambiguity anchors
  [7] Translator — literal JP/CN → English (preserve glossary, honorifics)
  [8] Editor — polish grammar, flow, natural English (never rewrite meaning)
  [9] Script Checks — deterministic: quote balance, bracket balance, CJK remaining
  [10] Consistency Checker — compare vs prior chunks (conditional, only on fail)
  [11] Verifier — sentence-by-sentence QC (report issues only, never rewrite)
  [12] Continuity Update — update character db, scene index

Post-Processing:
  [13] Combine — assemble approved chunks into full chapter
  [14] Rewriter — aggressive chapter-level smoothing
        Inputs: combined chapter + accumulated briefer context + glossary
        Allowed: rewrite sentences, merge/split, rephrase for flow
        Preserved: names, terms, honorifics, meaning
        Constraint: do NOT convert quote marks to backticks

  [15] Human Review
```

## .d Override System

`pipe.sh` sources override files in order:

1. **Global:** `/media/workspace/Projects/translation/pipe.d/*.conf`
2. **Per-book:** `<book>/pipe.d/*.conf`

Later files override earlier ones. Use for:

| Override | Example |
|----------|---------|
| Model paths | `MODEL_EDITOR="/path/to/model.gguf"` |
| Chunk size | `CHUNK_SIZE=12000` |
| Book-specific glossary | `GLOSSARY_APPROVED="$BOOK_DIR/pipe.d/glossary.md"` |
| Style guide | `STYLE="$BOOK_DIR/pipe.d/style.md"` |

## Key Rules

- **Models don't matter** — what matters is using a model that can handle the role
- **Rewriter does NOT convert quotes to backticks** — keep "" and '' consistent throughout
- **Parser never translates**, **Translator never interprets**, **Editor never invents**, **Verifier never rewrites**
- **Rewriter is the only stage allowed to rewrite** — and only at the chapter level, not per-chunk
- **Human decides canon** — pipeline produces structured review bundles for approval

## Starting a New Book

```bash
./pipe.sh init /media/workspace/Projects/translation/MyNewBook
# Copy EPUBs to raw/
./pipe.sh prep /media/workspace/Projects/translation/MyNewBook
# Create glossary.md, style.md, characters.md in pipe.d/
./pipe.sh pipe-all /media/workspace/Projects/translation/MyNewBook
./pipe.sh combine /media/workspace/Projects/translation/MyNewBook
./pipe.sh rewrite-all /media/workspace/Projects/translation/MyNewBook
```

Or in one shot:

```bash
./pipe.sh all /media/workspace/Projects/translation/MyNewBook
```

## Model Config Presets

Located in `~/infra/llama-loader/presets/`:

| Preset | Port | GPU | Context |
|--------|------|-----|---------|
| `1-parser.sh` | 8080 | 3060 | 8K |
| `2-glossary-briefer.sh` | 8082 | 3060 | 8K |
| `4-translate.sh` | 8083 | P40 | 8K |
| `3-agentic.sh` | 8080 | P40 | 262K |

## Related

- [[translation-pipeline]] — design philosophy and full role index
- [[translation-pipeline/roles/00-parser]]
- [[translation-pipeline/roles/10-rewriter]]
