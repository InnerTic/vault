---
title: "ADVANCED"
tags:
  - projects
---

Advanced Features
=================

## Auto persona routing (no user tags)

  if "error" in prompt: return "debugger"
  elif "why" in prompt: return "analyst"
  else: return "monday"

Classifier-based intent detection → persona selection.

## Persona blending (experimental)

  system_prompt = 70% monday + 30% analyst

Weighted merge of persona system prompts. Token cost scales with blended personas.

## Token optimization mode

  Only load active persona's system prompt.
  Reduces system prompt from ~2k tokens → ~200-400 tokens.
  Improves latency significantly on GGUF models.

## Hierarchical agents

  monday
    ├── analyst
    ├── debugger
    └── planner

Parent persona delegates to child personas within a chain.

## Next steps (from source)

  - Full CLI: gguf-agent run --agent debugger
  - Auto-router LLM (self-selecting personas)
  - Tool-using Hermes agent per persona
  - Memory-per-persona system (isolated context stacks)
  - Live switching in text-generation-webui extension
