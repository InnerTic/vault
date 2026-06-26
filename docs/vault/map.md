---
tags: [navigation, index]
aliases: [sitemap, map, vault-map]
modified: 2026-06-26
updated: 2026-06-22
---

# Vault Map

```
docs/                          ← Vault root (.obsidian/ lives here)
├── INDEX.md                   ← START HERE
├── CHANGELOG.md               ← Curated vault + dev changelog
├── CHANGELOG.raw.md           ← Verbose changelog (session records)
├── vault/
│   ├── QUICK-START.md         ← 🚨 Emergency recovery (system died, 5-min restore)
│   ├── changelog.md           ← Vault structure changes
│   ├── system-state.md        ← Current system snapshot
│   ├── VAULT-TODO.md          ← Pending vault tasks
│   ├── map.md                 ← THIS FILE — vault sitemap
│   │
│   ├── system/
│   │   ├── system-memory.md         ← ★ START HERE for rebuild
│   │   ├── drives-and-mounts.md     ← Storage layout, UUIDs, fstab, bind mounts
│   │   ├── dual-boot-recovery.md    ← Limine/MX Linux recovery, boot entry repair
│   │   ├── debian-setup-hoops.md    ← Debian 13 workarounds
│   │   ├── rebuild-notes.md         ← Build session records
│   │   ├── rebuild-script.sh        ← Full system recovery script
│   │   ├── workspace-symlink-strategy.md ← Symlink persistence plan
│   │   ├── backup-checklist.md      ← Backup reference
│   │   ├── akuma-index.md           ← Akuma recovery — index
│   │   ├── akuma-raw.md             ← Akuma recovery — raw facts
│   │   ├── akuma-state.md           ← Akuma recovery — derived state
│   │   ├── akuma-narrative.md       ← Akuma recovery — interpretive summary
│   │   └── AKUMA_VERSIONS.md        ← Akuma package versions manifest
│   │
│   ├── hardware/
│   │   └── gpu/
│   │       ├── config-notes.md      ← GPU driver + CUDA + llama.cpp
│   │       └── tesla-p40-vfio.md    ← P40 VFIO passthrough
│   │
│   ├── software/
│   │   ├── ai-tools/
│   │   │   ├── commands.md          ← AI command reference (llm, sdxl, textgen, oc)
│   │   │   ├── llama-setup.md       ← llama.cpp — build, GPU layout, P40
│   │   │   ├── forge-neo.md         ← Forge Neo — Debian + CachyOS
│   │   │   ├── textgen-webui.md     ← TextGen WebUI — Debian + CachyOS
│   │   │   ├── ollama-notes.md      ← Ollama GPU/CPU switching
│   │   │   ├── free-models.md       ← Free model reference
│   │   │   ├── free-providers.md    ← Free API providers
│   │   │   ├── cuda-12.9-setup.md   ← CUDA 12.9 on CachyOS
│   │   │   └── vlm-research.md      ← Vision-language model notes
│   │   ├── conky/
│   │   │   ├── system-cockpit.md    ← Unified Conky telemetry HUD
│   │   │   └── heat-aware-cockpit.md ← Thermal-reactive Conky cockpit
│   │   ├── kde/
│   │   │   ├── settings-backup.md   ← KDE Plasma settings backup/restore
│   │   │   ├── workarounds.md       ← Tracked KDE bugs
│   │   │   ├── temporary-hacks.md   ← Active KDE workarounds
│   │   │   └── dolphin-config.md    ← Dolphin file manager config
│   │   ├── opencode/
│   │   │   ├── plugins.md           ← OpenCode plugin recommendations
│   │   │   └── serena-mcp.md        ← Serena MCP toolkit
│   │   ├── prompt-hats/
│   │   │   ├── INDEX.md             ← 22 stable hats + E1–E8 experimental
│   │   │   └── ... (30 hat files)
│   │   ├── quartz/
│   │   │   ├── setup.md             ← Quartz v5 installation
│   │   │   └── container-plan.md    ← LXC container deployment
│   │   ├── searxng/
│   │   │   └── setup.md             ← SearXNG metasearch setup
│   │   ├── gaming/
│   │   │   └── gw2-multibox-wine-setup.md
│   │   ├── dev-setup.md             ← Python venv, git, shell, bootstrap
│   │   └── kvm-bridge-networking.md ← KVM/libvirt bridge (LAN DHCP for VMs)
│   │
│   ├── reference/
│   │   ├── architecture-snapshot.md      ← 🧭 Full homelab architecture
│   │   ├── ai-ssh-architecture.md        ← 🧩 Restricted ai-user SSH
│   │   ├── ai-vault-maintenance.md       ← AI agent guide: rules, levels, workflow
│   │   ├── dual-repo-workflow.md         ← Vault + dotfiles two-repo lifecycle
│   │   ├── lxc-build-log.md              ← 🧱 LXC 300 build + gold pipeline
│   │   ├── proxmox-ssh-infrastructure.md ← SSH key injection, agent access
│   │   ├── quartz-constitution.md        ← AI project constitution
│   │   ├── chat-ingestion-architecture.md ← Vault memory architecture
│   │   ├── index-retrieval-system.md     ← Index format + retrieval pipeline
│   │   ├── vault-query-scripts.md        ← Vault query scripts
│   │   ├── memory-reasoning-execution-pipeline.md
│   │   ├── libvirt-bridge-setup.md       ← Zero-touch KVM bridge
│   │   ├── keyd-stack.md                ← keyd upstream install + remap
│   │   ├── keyd-kde-wayland-f24.md       ← keyd + KDE Wayland F24 workaround
│   │   ├── key-locations.md             ← Key file locations
│   │   ├── commands.md                  ← Full command reference
│   │   ├── quick-commands.md            ← Condensed cheat sheet
│   │   ├── faq.md                       ← Common questions
│   │   ├── glossary.md                  ← Term definitions
│   │   ├── bugs-and-workarounds.md      ← Active upstream bugs
│   │   ├── boot-diagnostics.md          ← Boot timing debug
│   │   ├── lspci-reference.md           ← lspci cheat sheet
│   │   ├── lspci-akuma-output.md        ← Live PCI topology
│   │   ├── fixbot-chatlog.md            ← FixBot chat log
│   │   ├── knowledge-audit.md           ← Documentation knowledge audit
│   │   ├── ssh-key-setup.md             ← SSH key reference
│   │   ├── note-ingestion-contract.md   ← AI note processing rules
│   │   ├── agent-hallucination-techniques.md
│   │   ├── research-wiki-structure.md   ← Research wiki organization
│   │   ├── translation-pipeline-proposal.md
│   │   ├── translation-pipeline-spec.md
│   │   ├── vault-system-audit-2026-06-21.md
│   │   ├── key-locations.txt            ← Key file locations (flat text version)
│   │   ├── vault-evolution-timeline.md  ← Meta-history — index
│   │   ├── vault-evolution-timeline-raw.md
│   │   ├── vault-evolution-timeline-state.md
│   │   └── vault-evolution-timeline-narrative.md
│   │
│   ├── scripts/
│   │   ├── README.md                   ← Script index — reinstall order + GPU/AI + system
│   │   ├── lxc-ssh-access.md           ← SSH key distribution for containers
│   │   ├── REBUILD_SCRIPT.sh           ← Master rebuild script
│   │   ├── bootstrap.sh                ← Base bootstrap
│   │   ├── bootstrap-configs.sh        ← Config bootstrap
│   │   ├── check-fixes.sh              ← System fix checker
│   │   ├── fastfetch.md                ← Fastfetch setup
│   │   ├── forge-start.md              ← SD Forge startup
│   │   ├── install-tide-meslo.md       ← Tide/Meslo install
│   │   ├── llama-server.sh             ← llama-server startup
│   │   ├── toggle-gpu-profile.sh       ← GPU profile switcher
│   │   ├── toggle-p40.sh               ← P40 toggle
│   │   └── vm-bridge-setup.sh/fish     ← VM bridge setup (dual shell)
│   │
│   ├── projects/
│   │   ├── README.md                    ← Project index
│   │   ├── translation-pipeline.md
│   │   ├── translation-pipeline/        ← Pipeline v2 subdirectory (12 files)
│   │   ├── sd-webui-forge-neo.md
│   │   ├── homelab-service-contract.md
│   │   ├── vault-driven-container-profiles.md
│   │   ├── proxmox-gold-image-builder.md
│   │   ├── llama-loader-compiler-contract.md
│   │   ├── llama-loader/               ← Knowledge tree (architecture/, incidents/, changelog/)
│   │   ├── tmux-agent-interface.md
│   │   ├── tmux-capability-exploration.md
│   │   ├── tmux-agent-interface/       ← Tmux research (8 files: evolution, guides, unified ref)
│   │   ├── quartz-wiki-architecture.md  ← Quartz publishing architecture & rollout plan
│   │   ├── multi-agent-gpu-orchestration.md
│   │   ├── director-agent.md
│   │   ├── meta-scripts.md
│   │   └── multi-agent-gguf-switcher/  ← (8 files: ARCH, ADVANCED, CHECKLIST, IMPL, META, PERSONAS, README, ROUTING)
│   │
│   ├── context/
│   │   └── INDEX.md            ← Context docs index
│   │
│   ├── research/
│   │   ├── runbook-architecture.md        ← Runbook structure proposal
│   │   └── vault-organization-principles.md ← Vault org rules
│   │
│   └── archive/
│       ├── scratchpad.md
│       ├── storage-layout-plan.md
│       ├── implementation-workflow.md
│       ├── system-profile-cachyos.md
│       ├── akuma-recovery.log             ← Raw recovery log
│       ├── config_before_70pct.yaml       ← Hermes agent config (before tuning)
│       ├── config_final_confirmed.yaml    ← Hermes agent config (final)
│       ├── compression-change.diff        ← Hermes compression tuning diff
│       └── migration/                    ← Stale repo-separation planning (5 files)
```

## Navigation Paths

| Scenario | Where to Go |
|----------|-------------|
| I just reinstalled the OS | [[QUICK-START]] |
| I need to find something | [[INDEX]] |
| My GPU isn't working | [[hardware/gpu/config-notes]] |
| I need a command | [[software/ai-tools/commands]] or [[reference/commands]] |
| What does this term mean? | [[reference/glossary]] |
| Common questions | [[reference/faq]] |
| What's broken right now? | [[reference/bugs-and-workarounds]] |
| Drive full, where do I put things? | [[system/drives-and-mounts]] |
| How do I maintain the vault? | [[reference/ai-vault-maintenance]] |
| Tmux research & unified reference | [[projects/tmux-agent-interface]] |
