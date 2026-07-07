---
title: "Note Ingestion Contract"
tags:
  - reference
modified: 2026-06-26
---

# Note Ingestion Contract

**Type:** Reference · **Updated:** 2026-06-21

Processing contract for AI agents when converting raw Desktop notes into vault-ready knowledge.

## Objective

Reduce all input to meaningful signal, structured summaries, minimal loss of diagnostic value. Aggressively remove noise, repetition, and verbose logs.

## Classification

Classify each file as one of: `LOG`, `ERROR DUMP`, `SCRIPT`, `CONFIG`, `MIXED NOTES`, `UNKNOWN`.

## Log / Error Handling

### Always Do
- Extract error types and signatures
- Count repeated errors
- Keep only: first occurrence, last occurrence, representative stack trace (trimmed)
- Identify likely root cause patterns

### Always Remove
- Repeated stack traces, repeated identical lines
- Debug spam (heartbeat, polling, verbose loops)
- Timestamps unless relevant to pattern detection

### Compress Format
```
ERROR: <type/signature>
Frequency: N
First seen: <line>
Last seen: <line>
Likely cause:
- bullet list of hypotheses
Key snippet (trimmed):
- minimal stack trace or message
```

## Script / Config Handling

- Describe purpose in 1–2 sentences
- Extract: entry points, dependencies, environment assumptions, risky operations
- Remove redundant or repetitive comments

## Mixed Files

Split logically into "Operational content" and "Logs / errors". Process each separately.

## Global Compression

- Prefer structure over raw text
- Reduce size by removing repetition
- Preserve meaning, not form
- Never store full logs unchanged, preserve verbose debug output, or duplicate stack traces

## Output Format

```
# FILE SUMMARY
Type:
Purpose:
---

## KEY SIGNALS
- critical findings only

## ERRORS / EVENTS (if any)
Grouped and compressed as specified above

## SYSTEM INSIGHT (optional)
- inferred system behavior or failure mode

## DROPPED CONTENT REPORT
- what was removed and why (brief counts only)
```
