---
title: "Director Agent"
tags:
  - projects
modified: 2026-06-26
---

# Director Agent Architecture — opencode → local llama.cpp

**Status:** Proposed
**Date:** 2026-06-21

## Concept

Instead of opencode making tool calls directly, it acts as a **director** that tasks a local llama.cpp-loaded model with execution. The local model handles the actual tool interactions while opencode supervises, validates, and maintains context.

## Architecture

```
User
  │
  ▼
opencode (Director Agent)
  │  overseer, context manager, safety gate
  │
  ├── llama-server (localhost:8080)
  │     Hermes 20B / Qwen / other GGUF
  │     │
  │     └── Execution agent
  │           reads/edits files, runs commands, searches code
  │
  └── (fallback) direct tool calls for critical/unsafe operations
```

## Why

- Local model = no API costs, no data leaving machine
- opencode handles strategic reasoning (planning, validation)
- Local model handles tactical execution (file ops, bash, searches)
- opencode can run multiple local model instances for parallel work
- Falls back to direct tool calls for safety-critical operations

## Requirements

- llama-server running with model loaded (port 8080 or configurable)
- OpenRouter or direct API endpoint at localhost
- Structured prompt that translates opencode intent → local model execution
- Validation layer: opencode reviews local model output before committing

## Prompt Design

opencode sends structured tasks to the local model:

```
TASK: <description>
CONSTRAINTS: <safety rules>
CONTEXT: <relevant files/state>
EXPECTED OUTPUT: <format specification>
```

Local model executes, returns result. opencode validates, then iterates or commits.

## Directory

`vault/projects/director-agent/`
