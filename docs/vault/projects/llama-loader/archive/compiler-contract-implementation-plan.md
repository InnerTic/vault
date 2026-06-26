---
title: "Compiler Contract Implementation Plan"
tags:
  - projects
---

# Compiler Contract — Implementation Plan

**Date:** 2026-06-22
**Status:** Historical — architecture already implements this
**Source:** Desktop notes `Text File (4).txt`, raw AI conversation output

This document captures the raw implementation plan for enforcing single-authority CLI generation in llama-loader. The architecture at `architecture/compiler-authority.md` reflects the final state after this plan was executed.

## Goal

```
ONLY core/compiler/llama.cpp.sh can produce CLI flags
EVERYTHING ELSE is IR or state
```

Enforced structurally, not by discipline.

## Pipeline After Change

```
modes/*
   ↓ (IR only)
core/ir/normalize.sh
   ↓
core/compiler/llama.cpp.sh   ← ONLY CLI AUTHORITY
   ↓
core/runtime/run.sh
   ↓
llama-server
```

## Compiler Contract (`compile_cli`)

Single CLI emitter with required args (model, ctx, ngl), parallel, GPU split, GPU select, and network. All values come from IR, never from mode-level CLI construction.

## Enforcement

- `core/runtime/guards.sh` scans modes and builder for flag leakage (`--np`, `--main-gpu`, `--tensor-split`) and aborts if found outside compiler
- Top-level launcher (`llama-loader.sh`) must only select mode → call run.sh — no CLI building, no flag mutation, no IR mutation
- Entrypoint is the sole execution gate

## Why This Works

- Multiple writers for CLI syntax → eliminated
- Single writer = compiler, everything else = data only
- Removes entire class of bugs: `--np invalid argument`, split mismatches, GPU flag drift, llama.cpp ABI changes breaking random modes

## Final Architectural State

```
           IR (pure data)
                 ↓
     core/runtime/run.sh
                 ↓
 core/compiler/llama.cpp.sh  ← ONLY CLI AUTHORITY
                 ↓
           llama-server
```

---
Confidence: High
Sources: 1
Derived From:
  - Desktop notes/Text File (4).txt
---
