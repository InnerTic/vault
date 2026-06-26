---
title: "Vault Evolution Timeline Raw"
tags:
  - reference
modified: 2026-06-26
  - vault-evolution-timeline-raw
---

# Vault Evolution — Raw Facts (Immutable Log)

## Source Commands
- `find ~/vault/docs/vault/ -type f -name "*.md" -exec stat --format='%y %n' {} \;`
- `cd ~/vault && git log --all --oneline --reverse --name-only --format="%h %ad %s" 2>/dev/null`
- `cd ~/vault && git status --short`
- `cd ~/vault && git branch -a`

## File Inventory (Creation Timestamps)

### Jun-19 11:00 Batch
- reference/ssh-key-setup.md
- reference/fixbot-chatlog.md
- software/opencode/plugins.md
- software/opencode/serena-mcp.md
- software/kde/dolphin-config.md
- software/kde/settings-backup.md
- software/kde/workarounds.md
- software/kde/temporary-hacks.md
- reference/lspci-akuma-output.md
- reference/lspci-reference.md
- software/ai-tools/vlm-research.md
- software/ai-tools/ollama-notes.md
- software/ai-tools/free-models.md
- software/ai-tools/free-providers.md
- reference/glossary.md
- reference/faq.md

### Jun-19 12:55 Batch
- reference/bugs-and-workarounds.md
- reference/quick-commands.md
- reference/translation-pipeline-spec.md
- reference/translation-pipeline-proposal.md
- reference/research-wiki-structure.md
- software/searxng/setup.md
- software/gaming/gw2-multibox-wine-setup.md
- software/ai-tools/cuda-12.9-setup.md
- projects/translation-pipeline/roles/ (all role docs)
- projects/translation-pipeline/model-index.md
- projects/translation-pipeline/INDEX.md
- projects/translation-pipeline/README.md

### Jun-19 13:52
- software/kvm-bridge-networking.md

### Jun-20 06:50
- reference/proxmox-ssh-infrastructure.md

### Jun-20 07:10
- software/conky/system-cockpit.md

### Jun-20 19:32
- reference/architecture-snapshot.md

### Jun-20 19:35
- reference/lxc-build-log.md

### Jun-20 19:36
- reference/ai-ssh-architecture.md

### Jun-20 19:57
- reference/dual-repo-workflow.md

### Jun-21 06:00 Batch
- reference/memory-reasoning-execution-pipeline.md
- reference/index-retrieval-system.md
- reference/vault-query-scripts.md
- system/drives-and-mounts.md
- system/boot-diagnostics.md
- system/quartz-constitution.md
- software/quartz/setup.md
- hardware/gpu/config-notes.md (inferred from directory)

### Jun-21 07:47
- software/quartz/container-plan.md

### Jun-21 08:01
- software/ai-tools/forge-neo.md

### Jun-21 08:02
- software/ai-tools/llama-setup.md
- software/conky/heat-aware-cockpit.md

### Jun-21 12:55
- system/dual-boot-recovery.md

### Jun-21 18:07
- system/rebuild-notes.md
- system/debian-setup-hoops.md
- system/workspace-symlink-strategy.md

### Jun-21 18:08
- projects/director-agent.md

### Jun-21 18:27
- projects/homelab-service-contract.md
- projects/proxmox-gold-image-builder.md
- projects/vault-driven-container-profiles.md
- reference/note-ingestion-contract.md

### Jun-21 18:29
- projects/multi-agent-gpu-orchestration.md

### Jun-21 18:38
- projects/tmux-agent-interface.md

### Jun-21 18:39
- projects/tmux-capability-exploration.md

### Jun-21 19:32
- reference/knowledge-audit.md

### Jun-21 19:33
- reference/vault-system-audit-2026-06-21.md
- reference/key-locations.md
- reference/commands.md
- software/ai-tools/textgen-webui.md
- software/dev-setup.md

### Jun-21 19:51
- projects/llama-loader/INDEX.md
- projects/llama-loader/architecture/compiler-authority.md
- projects/llama-loader/architecture/ir-schema.md
- projects/llama-loader/architecture/execution-planner.md

### Jun-21 19:52
- projects/llama-loader-compiler-contract.md
- projects/llama-loader/incidents/np-flag-regression.md
- projects/llama-loader/incidents/tensor-split-migration.md

### Jun-21 19:57
- reference/dual-repo-workflow.md (updated)

### Jun-21 20:03
- reference/ai-vault-maintenance.md

### Uncommitted (git status ??)
- docs/vault/system-state.md
- docs/vault/scripts/lxc-ssh-access.md
- dotfiles/scripts/archive-script.sh
- dotfiles/scripts/forge-llm.sh
- dotfiles/scripts/textgen-start.sh
- dotfiles/scripts/vault-restore-all.sh
- dotfiles/scripts/vault-restore.sh
- dotfiles/scripts/vault-snapshot.sh
- dotfiles/tmux/ (directory)
- script-reference/ (directory)

## Git Repository State
- vault.git: 182 files, tagged batch-a-copied
- dotfiles.git: 251 files, tagged pre-migration-baseline
- infra.git: 35 files, tagged batch-c-copied
- infra structure (reabsorb commit): builder/, core/, introspect/, lib/, modes/, presets/, state/, llama-loader.sh, llama-loader.old, lxc-bootstrap.sh, lxc-provision.sh, lxc/core.sh, lxc/fish.sh, lxc/zsh.sh, lxc/aliases.sh, lxc/fonts.sh, forge-start.sh, healthcheck.sh, llama-server.sh, check-fixes.sh, live-env-setup.sh, toggle-gpu-profile.sh, toggle-p40.sh, build-gold-lxc.sh, test-cleanup-backups.sh

## Migration Batches
- Phase 0: classified 250 files across 4 categories (VAULT: 178, DOTFILES: 35, INFRA: 37, UNKNOWN: 0)
- Phase 1: plan A→B→C→D→Validate→Cleanup→Cutover
- Phase 2: all batches committed and tagged
