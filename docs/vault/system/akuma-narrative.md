# Akuma Recovery Log — Narrative Summary

> INTERPRETIVE. Based on raw log + derived state. Not authoritative — subject to revision when new evidence appears.

## The Story

### Pre-Overhaul (Before 2026-04-19)
The original layout put everything on a single SATA setup: root and boot on sdb, /var on sda, /home on NVMe. Games lived in /home. A 3.6TB HDD handled backup. The NVIDIA driver was the main pain point — latest drivers would break on the rolling kernel, requiring a pinned version.

### The Overhaul (2026-04-19)
Something changed the disk layout. The recovery log explicitly calls this out. The games got moved to /var via bind mount (keeping /home lean). The storage strategy shifted: separate volumes for different risk profiles — /var could grow without filling root, /home was isolated on NVMe for performance.

### The Archive (2026-05-13)
The old layout was archived as reference. The log includes the exact commands that worked, not suggestions. This is important: the person who wrote this had already tested every command. Nothing was guessed.

### What the Log Is Trying to Say
The key message is buried at the bottom:

> "if you want the nvidia setup, here are the commands, versions, locations, and why it took so long"

The author knew that without this document, the next AI (or human) would waste time rediscovering what was already solved. The post office metaphor: if nobody updates the notice, you walk to the wrong mailbox.

## Meta-Observation

The log is written in two voices:
1. **Factual** — tables, UUIDs, commands. Dry. Unambiguous.
2. **Conversational** — "that's all context to keep the next ai tomorrow or next week from wasting my time because someone forgot to update the postoffice with enough warning"

The factual voice tells you what to do. The conversational voice tells you why it matters. Both are useful. Neither is sufficient alone.

## Confidence

- Low confidence on what changed during the 2026-04-19 overhaul (log doesn't detail before/after)
- High confidence on the pre-overhaul state (exact UUIDs, commands, and mount points)
- High confidence on NVIDIA stack (explicitly tested and verified)

Derived from: Layer 1 (akuma-raw.md) + Layer 2 (akuma-state.md)
