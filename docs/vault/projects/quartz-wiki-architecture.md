---
title: "Quartz Wiki Architecture"
tags:
  - projects
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
        │
        ▼
 wiki.home.arpa
```

### LXC: quartz

| Property | Value |
|----------|-------|
| LXC ID | 301 (quartz-base, existing) |
| IP | 172.16.1.44 |
| Runs | nginx/caddy, node, quartz, git |

### Publishing Flow (Manual → Auto)

```
edit → git push → (hook) → git pull → quartz build → site updated
```

Goal: `Ctrl+S`, `git push`, done.

## Key Decision: rsync over symlink

Symlink approach produced recursive loops (`vault → vault`, `→ → →`). Quartz wasn't broken — the filesystem topology was.

```
vault
  ↓ rsync --delete (NOT symlink)
Quartz content
```

Predictable, no symlink issues, disposable copy.

## Rollout Phases

### Phase 1 — Desktop: Manual Build
Current approach: build Quartz on Akuma, serve locally. Proves the concept.

### Phase 2 — LXC: Manual Build
Move Quartz into LXC container. Manual git pull, rsync, build. Same flow, different host.

### Phase 3 — LXC: Auto-Publish
Git post-receive hook triggers build. `git push` → site updates automatically.

### Phase 4 — DNS + Polish
`wiki.home.arpa` with Pi-hole DNS. Homepage integration. Runbooks.

## Future Possibilities

- **Homepage integration**: Wiki link on the dashboard
- **AI-assisted docs**: Conversation → AI generates note → git commit → Quartz publish
- **Homelab runbooks**: Recovery guides for OPNsense, Proxmox, SSH, containers
- **Public/private split**: `vault/public/` → Quartz, `vault/private/` → Obsidian only

## Related Docs

- [[software/quartz/container-plan]] — LXC setup steps
- [[software/quartz/setup]] — Quartz installation
- [[homelab-service-contract]] — one-service-per-container policy
