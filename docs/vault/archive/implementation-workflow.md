---
title: "Implementation Workflow"
tags:
  - archive
modified: 2026-06-26
---

# Storage Layout Implementation Workflow
## Canoncial workflow from chat with Monday Kitsune (2026-04-19)

## PHASE 1: PREPARATION (DO NOT RUN - REVIEW ONLY)

### 1. Verify current drive layout
lsblk -f  # Shows UUIDs and mount points

### 2. Backup critical AI configurations (DO THIS FIRST)
mkdir -p ~/backups
tar -czvf ~/backups/openclaw_dotfiles.tar.gz ~/.openclaw ~/.opencode
cp
