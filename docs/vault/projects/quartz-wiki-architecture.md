---
title: "Quartz Wiki Architecture"
tags:
  - projects
modified: 2026-06-26
---

# Quartz Wiki — Architecture & Rollout Plan

**Status:** Proposed
**Updated:** 2026-06-22
**Source:** Synthesized from session design discussion

## Design Principle

```
Obsidian = Authoring
Git      = Version History
Quartz   = Publishing
Nginx    = Delivery
```

Quartz is **not** the vault. Quartz is a **publisher**. If Quartz disappeared tomorrow, the vault survives, the history survives, nothing important is lost.

## Source of Truth

```
~/dotfiles/docs
```

This is where Obsidian edits happen, Git commits happen, AI documentation gets written, and knowledge lives.

## Architecture

```
Obsidian Desktop
        │
        ▼
     Git Push
        │
        ▼
   Quartz LXC
        │
        ▼
      Nginx/Caddy
