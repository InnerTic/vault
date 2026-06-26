---
title: "ROUTING"
tags:
  - projects
modified: 2026-06-26
---

Runtime Switch Mechanisms
=========================

Three methods for selecting a persona at runtime.

## A. CLI flag (cleanest)

  llama-cli -m model.gguf --agent monday

Internally: agent.system_prompt = kv["agent.monday.system_prompt"]

## B. Inline chat trigger

  User input: /agent debugger Why is my container crashing?
  Parser: persona = "debugger", prompt = "Why is my container crashing?"

## C. Hidden message prefix

  <|agent:analyst|>
  Explain system load spike

  Parser: agent = "analyst", prompt = "Explain system load spike"

Parser priority: CLI flag > hidden prefix > inline trigger > agent.default
