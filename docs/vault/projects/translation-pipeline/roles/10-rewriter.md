---
title: "10 Rewriter"
tags:
  - projects
  - translation-pipeline
modified: 2026-07-19
---

# Rewriter

**Port:** 8087 | **GPU:** 3060 (CUDA0) | **Context:** 4096

## Position in Pipeline

The Rewriter is a **chapter-level** stage, not a chunk-level stage. It operates on the **combined chapter** after all chunks have been translated, edited, verified, and assembled.

## Role

Takes the assembled chapter (all chunks stitched into one continuous text) and aggressively smooths choppy web novel prose into natural English. This is the **liberty layer** — the one stage in the pipeline that is allowed to rewrite.

**Allowed:** rephrasing awkward sentences, merging/splitting for flow, adjusting paragraph structure, smoothing transitions, fixing stilted dialogue, compressing verbose phrasing, improving readability across chunk boundaries.

**Forbidden:** changing plot points, altering character voice, dropping names/terms/honorifics, adding content not implied by the original, inventing details, changing meaning.

## Philosophy

The Editor (role 4) is tightly constrained — it polishes grammar and flow but never rewrites. The Rewriter is the opposite: it takes the same input and is expected to rewrite aggressively for naturalness. If the original translation is choppy (as web novel MT often is), the Rewriter smooths it into something a native English reader would enjoy.

This is where the pipeline **stops being literal** and **starts being readable**.

The Rewriter also receives the accumulated **Briefer context** (scene analysis, character relationships, ambiguity anchors) so it can make informed rewriting decisions about tone, voice, and narrative flow.

## Inputs

- Combined chapter text (all chunks assembled)
- Accumulated Briefer context (per-chunk scene analysis)
- Approved glossary

## Constraints

- Preserve ALL names, glossary terms, honorifics (exact match)
- Preserve core meaning of every sentence
- Do NOT shift character voice or personality
- Do NOT add subtext, emotion, or drama not in the original
- Do NOT remove content (even if verbose)
- Do NOT convert quote marks to backticks — keep "" and '' consistent throughout
- Use briefer context for scene/character continuity across chunks

## Change Log

Outputs alongside the rewritten chapter:

- Sentences rewritten: [count]
- Sentences merged: [count]
- Sentences split: [count]
- Tone adjustment: [none/mild/moderate]
- Structural changes: [paragraph reorder, dialogue reformat, cross-chunk smoothing]

## Pipeline Order

```
[1-8] Chunk pipeline (per chunk)
         ↓
[9]    Combine chunks → full chapter
         ↓
[10]   Rewriter — aggressive chapter-level smoothing
         ↓
[11]   Human review
```

## Scripts

- `chapter-rewrite.sh` — main rewriter (takes combined chapter + briefer context + glossary)
- `combine-chapter.sh` — assemble approved chunk outputs into a chapter

## Model Notes

Any model with strong English fluency and creative rewriting ability. Dense models preferred over MoE for per-token reliability.

- **Floppa-12B-Gemma3-Uncensored** — good balance of creativity vs constraint adherence
- **Mistral-7B** — too conservative, tends to just polish
- **Qwen3.6-27B** — excellent rewriting but heavy for this role; better used on Translator
