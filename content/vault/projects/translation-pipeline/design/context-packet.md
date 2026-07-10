---
title: "Context Packet (Translation Brief)"
tags:
  - projects
  - translation-pipeline
modified: 2026-07-10
---

# Context Packet Architecture

## Problem

The pipeline has a **data flow gap**:

```
Parser (00) ──→ canon/parser/ ──→ Translate reads entities
Glossary (01) ──→ canon/glossary-approved.md ──→ Translate reads terms
Briefer (02) ──→ canon/briefer/ ──→ NOTHING reads this (except reconcile)
```

The briefer generates rich narrative context (character state, motivations, POV, plot progression) but it's a dead-end artifact. Only the glossary reconciliation step touches it. Translate and rewrite never see the narrative context they'd benefit from most.

## Solution: One Context Document

Replace the multi-source input pattern with a single **context packet** per chapter:

```
canon/context/ch0NNN.md
```

Assembled from:
| Source | Provides |
|--------|----------|
| Parser | Structure: who, where, when |
| Glossary | Canonical names + terms for this chapter |
| Briefer (repurposed) | Narrative: POV, character state, intent, previous context |

The translator receives **one document** containing everything it should know before translating the first sentence.

## What the Packet Contains

```
=== Chapter Brief ===

POV: <character>

Purpose: <why this chapter exists>

Character State:
  <name>: <emotional state, goals, constraints>
  ...

Important Terms:
  <term>: <canonical English, usage rules>

Previous Context: <what happened before this chapter>

Active Plot Threads: <unresolved threads relevant here>

Scene Flow: <high-level scene breakdown>
```

## Pipeline Change

```
Before:
  03-translate.py → reads: parser/ + glossary-approved.md

After:
  02-context.py    → reads: parser/ + glossary-approved.md + briefer/
                   → writes: canon/context/ch0NNN.md
  03-translate.py  → reads: canon/context/ch0NNN.md (single file)
  05-rewrite.py    → reads: canon/context/ch0NNN.md (single file)
```

## Benefits

- Translator has one authoritative context document
- No source-hunting across 3-4 directories
- Context packet can be cached, versioned, inspected
- Easy to add more sources (timeline, relationship graph) without changing translator
- Renames "briefer" from a dead-end summary job to a critical assembly step

## Compute Split

| Step | Model Tier | Rationale |
|------|-----------|-----------|
| 00-parser | Big (P40/8080) | Full chapter structural analysis |
| 01-glossary | Small (3060/8081) | Term extraction from clean text |
| 02-context | Small (3060/8081) | Assembly + light narrative generation |
| 03-translate | Big (P40/8083) | Heavy translation |
| 05-rewrite | Big (P40/8080) | Full literary rewrite |

Parser is the heavy lift. Glossary and context assembly can run on the 3060.
