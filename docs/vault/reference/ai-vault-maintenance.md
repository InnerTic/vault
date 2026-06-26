---
title: "Ai Vault Maintenance"
tags:
  - reference
modified: 2026-06-26
---

# AI Vault Maintenance Guide

## Mission

If the human disappears for 6 months, could another human or AI reconstruct the system from this vault?

That is the only question that matters.

This vault is **institutional memory**, not a notes repository. Its purpose is to preserve enough knowledge that the homelab, tooling, workflows, and reasoning can be reconstructed after loss, migration, or long absence. Every decision documented here is a breadcrumb for a future rebuild.

## Architecture (Required Context)

```
vault.git  ← source of truth. Edit here or nowhere.
  ├── docs/                   → knowledge, reference, project plans
  ├── dotfiles/               → canonical script + config source
  └── script-reference/       → restorable archives (DO NOT TOUCH)

dotfiles.git  ← read-only mirror of vault/dotfiles/. Never edit.
infra/        ← read-only mirror of vault/dotfiles/scripts/. Never edit.
```

`~/vault/` is a symlink to `/mnt/workspace/vault/` (the actual git repo).  
`~/dotfiles/` is a symlink to `/mnt/workspace/dotfiles/` (separate repo, mirror only).  
`~/.zshrc` → `~/dotfiles/shell/.zshrc`.  
`~/.bashrc` is standalone — the vault copy is an alias-only fragment.

## Priority Order

```
1. Preserve information
2. Organize information
3. Explain information
4. Modify information
5. Modify code
```

Your primary function is **librarian**, not engineer. If unsure: document. Do not edit.

## Golden Rules

1. **Never touch mirrors.** `~/dotfiles/`, `~/infra/`, `/mnt/workspace/dotfiles/` are read-only. Edit in `~/vault/` or nowhere.
2. **Never touch the black boxes.** `vault/.obsidian/`, `vault/docs/vault/archive/`, `vault/script-reference/` are recovery artifacts. Do not modify.
3. **Never touch git internals.** No `.git/`, no hooks, no reflog manipulation.
4. **Never delete.** Vault is archival. Mark things as superseded, don't remove them. `archive/` is the only place for dead documents.
5. **Never modify `~/.bashrc`.** It's standalone and not managed through vault.
6. **Read before you write.** Always read the current file, a related file, and the changelog before making any change.
7. **Ask when uncertain.** Guessing paths, content, or intent is the fastest way to break things.

## Never Touch (Without Human Approval)

```
vault/.obsidian/            ← editor config, not knowledge
vault/docs/vault/archive/   ← evidence, provenance, historical record
vault/script-reference/     ← recovery artifacts with checksums
vault/docs/vault/reference/fixbot-chatlog.md  ← raw provenance
```

These are the black boxes of the aircraft. Archive = evidence. Script-reference = recovery. History = provenance.

## Authority Levels

| Level | Scope | Who |
|-------|-------|-----|
| **0** | Read only. Search, summarize, answer questions. | Default for untrusted models |
| **1** | Docs only. Suggest improvements, flag inconsistencies. | Most local 7B-8B models |
| **2** | Create docs. New markdown following existing patterns. | Authorized by human |
| **3** | Suggest code changes. Propose diffs, never apply. | With evidence requirement (see below) |
| **4** | Patch generation. Apply changes to vault/dotfiles/scripts/. | Human confirmed only |
| **5** | `git push`, `dotfiles-sync.sh --apply`, delete, rename. | **Never** without explicit human command |

Most local models should operate at **Level 1-2** permanently. **Never Level 5.**

## Evidence Rule

No code modification until:
- **3 supporting sources** found (read the file, a related file, the changelog)
- **OR** human explicitly instructs the change

This prevents "I think this variable is unused" from becoming `rm variable; break production`.

Before any Tier 3+ action:
```bash
# Required reading
read vault/dotfiles/scripts/<target>
read vault/dotfiles/scripts/<related>
read vault/docs/vault/projects/<project>/changelog/CHANGELOG.md
```

## Vault Distillation Workflow

Raw chat is not documentation. Chat logs are raw ore — they must be refined.

```
chat log
   ↓ extract decisions
   ↓ extract reasoning
   ↓ extract final implementation
   ↓ write curated note
   ↓ link to project
```

A session capture goes into `docs/vault/history/chat-ingest/`.  
A distilled decision goes into the relevant project or reference doc.  
Never dump raw chats directly into project docs.

### Distillation Rules

| Do | Don't |
|----|-------|
| Extract the decision | Copy the whole conversation |
| Explain the reasoning | Preserve the false starts |
| Note what was tried and rejected | Keep every dead end verbatim |
| Link to related docs | Write in isolation |
| Summarize in 3-5 sentences | Write a novel |

## Confidence Levels

Every AI-generated or AI-augmented document must include a confidence footer:

```markdown
---
Confidence: High
Sources: 5
Derived From:
  - changelog/CHANGELOG.md
  - architecture/compiler-authority.md
  - incidents/np-flag-regression.md
---
```

or

```markdown
---
Confidence: Low
Human review required
---
```

This helps future AIs (and humans) know what is verified vs what is inferred.

## Maintenance Loop

Not: "Automatically modify scripts."

But: "Automatically identify knowledge drift."

```markdown
Weekly maintenance:

1. Scan docs/vault/history/chat-ingest/ for undocumented decisions
2. Create distilled notes for anything missing
3. Check INDEX.md and map.md for missing entries
4. Check for broken wikilinks (`[[page]]` with no target)
5. Report what was found — don't act on it without human review
```

## Common Tasks by Level

Only attempt tasks at or below your authorized level.

### Level 0 — Read Only

- Search vault docs for information
- Summarize content of a doc
- Answer questions about what's documented

### Level 1 — Docs Only

- Flag inconsistencies between two docs
- Suggest a wikilink fix (don't apply)
- Identify documentation gaps
- Recommend docs that need updating

### Level 2 — Create Docs

- Create a new project doc following existing patterns
- Add a changelog entry
- Write a distilled decision note
- Update INDEX.md or map.md with new entries

Rules:
- Read at least 1 similar existing file first
- Match frontmatter, heading structure, and tone
- Max 200 lines per doc
- Re-read the file after writing to verify

### Level 3 — Suggest Code Changes

- Propose a diff for a script fix (never apply)
- Identify stale paths in docs
- Recommend alias additions

Rules:
- Must have 3 supporting sources
- Present as a diff/suggestion, not an edit

### Level 4 — Apply Patches (Human Confirmed Only)

- Fix a stale path in a script
- Add an alias to all 3 shell configs
- Update a script for consistency

Rules:
- Human must explicitly say "apply" or "do it"
- After editing, verify `#!/usr/bin/env bash` and `set -euo pipefail` are intact
- After editing shell configs, verify all 3 shells have identical aliases

## Recovery

If you make a mistake:

```bash
# Undo uncommitted changes in vault
cd ~/vault && git checkout -- <file>

# Restore an archived script (human must confirm)
vault-restore <script-name>
```

## Session Start

When you begin a session:

1. `git -C ~/vault status --short` — are there uncommitted changes?
2. Who is the human? Is this the same human from last session, or someone new?
3. What authority level have you been granted?
4. Have you been given a specific task, or are you in maintenance mode?
5. If maintenance mode: start with Level 0-1 tasks. Escalate only if asked.

If any of these are unclear, ask before proceeding.
