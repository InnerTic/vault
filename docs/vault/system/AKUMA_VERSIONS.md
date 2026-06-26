---
title: "AKUMA VERSIONS"
tags:
  - system
---

AKUMA SYSTEM EVOLUTION — VERSION PROGRESSION

This documents how each version built on the prior one, showing the
architectural maturation of the Akuma system from raw setup to
modular test rig.

================================================================
VERSION 1 — FOUNDATION (dotfiles + bootstrap)
================================================================

Source: AGENTS.md, README.md, INDEX.md, debian-setup-hoops.md
Date: 2026-06-06 initial

What it is:
  The bare-metal bootstrap. Dotfiles repo, ssh config, zshrc,
  gitconfig, bootstrap.sh — the system comes alive when you
  clone and run it.

Key components:
  - dotfiles/ as portable user environment
  - bootstrap.sh for distro-agnostic setup
  - ssh/config for host management (172.16.7.1 Proxmox)
  - .zshrc with AI aliases (llm, textgen, llmk, etc.)

What it lacks:
  - No model management layer
  - No GPU routing abstraction
  - No test rig or evaluation harness
  - Docs are scattered, no index beyond INDEX.md

Why it matters:
  This is the ground truth. Everything above runs on this.
  Without the dotfiles/bootstrap, nothing else exists.

================================================================
VERSION 2 — GPU + MODEL INFRASTRUCTURE
================================================================

Source: gpu-config-notes.md, llama-setup.md, lspci-akuma-output.md
Built on: Version 1 (bootstrap provides the shell, git, ssh)

What it adds:
  - Dual-GPU architecture: RTX 3060 (GPU0, sm_86) + Tesla P40 (GPU1, sm_61)
  - llama.cpp built with CMAKE_CUDA_ARCHITECTURES="61;86"
  - CUDA 12.9 at /opt/cuda/, CUDA 12.4 at ~/.local/cuda-12.4/
  - llama-server at /mnt/workspace/llama.cpp/build/bin/
  - llama-loader at ~/.local/bin/llama-loader (interactive GGUF selector)
  - GPU-specific kernel cmdline fixes for P40 PCIe Gen3

New capabilities from V1:
  - Can run models locally instead of cloud-only
  - Can split work across two GPUs of different generations
  - Has a model selector instead of hardcoded paths

What it lacks:
  - No prompt routing (all CLI flags scattered)
  - No GPU profile abstraction
  - No server lifecycle management
  - No evaluation/testing layer

Risk zone:
  GPU selection ambiguity, CUDA_VISIBLE_DEVICES shifting,
  mixed split modes, no config abstraction = "voodoo reboot rituals"

================================================================
VERSION 3 — SERVER LIFECYCLE + PIPELINE
================================================================

Source: Untitled.md (translation pipeline review), start-server.sh, stop-server.sh, pipe.sh
Built on: Version 2 (models can run, now need orchestration)

What it adds:
  - Server lifecycle: start-server.sh, stop-server.sh per port
  - Health check wait (curl --max-time 120s)
  - Pipe.sh: sequential pipeline of 9+ stages
  - jq-based prompt assembly (structured, no heredoc chaos)
  - Stateless servers: start -> query -> stop per stage
  - Conditional consistency gate (skip checker if clean)

New capabilities from V2:
  - Reproducible per-stage inference (no stale KV corruption)
  - Structured prompts instead of shell string concatenation
  - Early exit optimization for clean chunks
  - Each stage gets isolated model + port + GPU + responsibility

Risk zones discovered:
  - GLOSSARY_CANDIDATE uncontrolled duplication (no staging)
  - curl silent failures -> jq reads null -> corrupted state
  - Editor output treated as authoritative (lose translation traceability)
  - Fixed ports (8081-8088) = no parallel book support
  - No GPU lock files = race condition if parallelized later

================================================================
VERSION 4 — MODEL KNOWLEDGE + BEHAVIORAL ANALYSIS
================================================================

Source: Untitled 1.md (llama.cpp cache analysis), Untitled 2.md (DeepSeek MoE), Untitled 5.md (OpenClaw + test rig)
Built on: Version 3 (pipeline runs, now measuring and comparing)

What it adds:
  - Cache mechanics understanding: LCP similarity 0.94-0.97,
    prompt eval collapse (7369->465 tokens), decode stability ~57 t/s
  - CUDA graph reuse: 28090->29500 graphs reused, massive efficiency
  - Context checkpoints: 200 MiB each, restore-invalidate-continue pattern
  - MoE model behavioral analysis: DeepSeek R1 distillation,
    tool loop collapse (narrative agent loop without grounding)
  - Vision model placement: 3060 for vision encoder, P40 for LLM
  - imatrix quantization understanding: importance-aware quantization
  - OpenClaw + llama.cpp config: remote gateway mode, no Ollama

New capabilities from V3:
  - Can measure WHY the pipeline works (not just that it works)
  - Can compare model families (Gemma APEX vs DeepSeek MoE vs OSS)
  - Can run vision models on the 3060 without stealing P40 VRAM
  - Understands failure modes (tool loops, cache corruption, quantization loss)

What it lacks:
  - Config files are still inline/shell variables
  - No unified test rig
  - Stress testing is ad-hoc
  - No automated A/B comparison

================================================================
VERSION 5 — MODULAR TEST RIG
================================================================

Source: Untitled 5.md (continued), config/models.yaml, config/endpoints.yaml, config/run_profiles.yaml
Built on: Version 4 (knowledge of models + failure modes + pipeline)

What it adds:
  - Directory structure: models/, configs/, servers/, workloads/, metrics/, logs/
  - config/models.yaml: named models (gemma26b, oss20b, qwen32b) with paths
  - config/endpoints.yaml: endpoint abstraction (url, timeout)
  - config/run_profiles.yaml: temperature/max_tokens/concurrency presets
  - runners/: single.py, batch.py, stress.py, compare_models.py, long_context.py
  - metrics/: latency.py, tokens.py, consistency.py, drift.py, gpu_stats.py
  - GPU profiles: p40_only, dual_gpu_split, 3060_only (env files)
  - Context profiles: 4k, 16k, 32k (json)
  - Workloads: stress (recursive prompt, KV cache bomb), translation (epub, glossary)

New capabilities from V4:
  - Stop hardcoding model paths -> load from config
  - Measurable, not just pokable (latency, drift, GPU stats)
  - Reproducible runs (config.yaml is the source of truth)
  - Stress testing with recursive prompts and KV cache pressure
  - Translation pipeline: epub -> chunk -> glossary -> translate -> merge
  - GPU profile switching without command-line juggling

================================================================
VERSION 6 — ARCHIVAL + STORAGE STRATEGY
================================================================

Source: Untitled 3.md (USB topology, cold storage, Clonezilla)
Built on: Version 1 (drive layout) + Version 4 (models are large, need storage)

What it adds:
  - 3-layer storage: active (NVMe/SSD) -> semi-active (SATA/SSD) -> cold (HDD, powered off)
  - Clonezilla for state snapshots (system state, not data)
  - Stateful system, stateless data separation
  - USB 10Gbps topology mapping (3 xHCI controllers, each with USB2 + 10Gbps)
  - "Cold does not mean forgotten" — periodic read tests
  - Models live on external mounts, not in Clonezilla images

New capabilities from V1/V4:
  - Can rebuild entire system from Clonezilla in hours
  - Large models don't bloat images (they're mounted, not imaged)
  - Cold archive server is more resilient than always-on aging disks
  - Can map physical USB ports to controllers via lsusb -t

================================================================
VERSION 7 — IMAGE GENERATION + AVATAR PIPELINE
================================================================

Source: Untitled 4.md (SD prompts, Wednesday avatar, NVIDIA driver VRAM)
Built on: Version 2 (GPU infra) + Version 4 (VRAM understanding)

What it adds:
  - Stable Diffusion prompt engineering (photorealistic, cinematic)
  - Wednesday Addams avatar concept (cosmic skull, anaglyph, volumetric)
  - "Guild of the Untutored" thematic prompts (terminal cult aesthetic)
  - NVIDIA proprietary driver VRAM gains over nouveau
  - xformers, --medvram, attention slicing for VRAM optimization
  - Small -> upscale workflow for memory-constrained generation

New capabilities from V2/V4:
  - SD prompts optimized for local Forge Neo at /mnt/workspace/sd-webui-forge-neo
  - Proprietary drivers unlock more effective VRAM (less fragmentation,
    better CUDA optimization, xformers support)
  - Can generate themed avatar images without cloud services

================================================================
PROGRESSION SUMMARY
================================================================

V1 (Foundation)    -> dotfiles, bootstrap, shell, ssh
V2 (GPU+Models)    -> dual-GPU llama.cpp, model selector, server
V3 (Pipeline)      -> orchestration, lifecycle, jq prompts, conditional gates
V4 (Knowledge)     -> cache analysis, MoE behavior, imatrix, vision placement
V5 (Test Rig)      -> config-driven, metrics, stress, A/B comparison
V6 (Storage)       -> 3-layer archive, Clonezilla state snapshots, USB topology
V7 (Images)        -> SD prompts, avatar pipeline, VRAM optimization

Each version solved a problem the prior version created:
  V1 had no models       -> V2 added GPU + model infrastructure
  V2 had no orchestration -> V3 added server lifecycle + pipeline
  V3 had no measurement  -> V4 added cache analysis + model knowledge
  V4 had no structure    -> V5 added config-driven test rig
  V5 had no archival     -> V6 added 3-layer storage strategy
  V5 had no imaging      -> V7 added SD prompt + avatar pipeline
