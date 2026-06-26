---
title: "META"
tags:
  - projects
modified: 2026-06-26
---

# "META"

GGUF Metadata Schema Extension
===============================

Extend GGUF kv-store with namespaced agent metadata:

  agent.default = "monday"

  agent.monday.system_prompt    = "<persona prompt>"
  agent.monday.style            = "analytical"

  agent.analyst.system_prompt   = "<persona prompt>"
  agent.analyst.style           = "forensic"

  agent.debugger.system_prompt  = "<persona prompt>"
  agent.debugger.style          = "procedural"

Schema
------

  agent.<name>.system_prompt  — full system prompt blob
  agent.<name>.style          — one-word style tag (optional)
  agent.default               — fallback persona key

Usage: build_multi_agent_metadata() → dict → inject into GGUF kv-store.
