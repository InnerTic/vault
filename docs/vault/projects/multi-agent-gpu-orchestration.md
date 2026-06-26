---
title: "Multi Agent Gpu Orchestration"
tags:
  - projects
modified: 2026-06-26
  - multi-agent-gpu-orchestration
---

# Multi-Agent GPU Orchestration

**Status:** Proposed
**Date:** 2026-06-21

## Concept

Run multiple models across both GPUs simultaneously, each serving a different agent role, with peer-to-peer communication and fallback to online models.

## Architecture

```
                    ┌──────────────────┐
                    │  Online API      │
                    │  (GPT/Claude/etc)│
                    └────────┬─────────┘
                             │
                    fallback / augment
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌─────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  Fast Agent      │  │  Heavy Agent     │  │  Tool Runner     │
│  RTX 3060 :8080  │◄─┤  Tesla P40 :8081 │  │  (any GPU) :8082 │
│  4-7B model      │  │  20B-35B model   │  │  code/critic     │
│  quick responses │  │  deep reasoning  │  │  specialist      │
└─────────────────┘  └──────────────────┘  └──────────────────┘
        │                    │                     │
        └────────────────────┴─────────────────────┘
                          │
                   opencode / custom
                   orchestrator
```

## GPU Budget

| GPU | Model Size | Use Case |
|-----|-----------|---------|
| RTX 3060 (12GB) | 4-7B Q4-Q8 | Fast agent, chat, tool dispatch |
| Tesla P40 (24GB) | 20B-35B Q4 | Deep reasoning, planning, analysis |
| Either | — | Code execution, formatting, or online fallback |

## Agent Roles

- **Fast Agent** (3060, :8080) — handles simple queries, routing, classification, quick edits
- **Heavy Agent** (P40, :8081) — complex reasoning, planning, multi-step tasks
- **Online Fallback** — when local models aren't enough, route to API

## Communication

- Models talk via OpenAI-compatible API on their respective ports
- opencode or a custom orchestrator routes between them
- Agents can pass context: "Heavy, the user wants X. Fast checked Y. Here's the combined picture"
- Online model as arbiter or for tasks beyond local capability

## Open Questions

- Which small model for the 3060? (Qwen2.5-Coder-7B, Llama-3.2-8B, Gemma-3-4B)
- Orchestrator: opencode plugin, custom script, or agent framework?
- Context passing format between agents?
- How to handle concurrent requests to the same GPU?
