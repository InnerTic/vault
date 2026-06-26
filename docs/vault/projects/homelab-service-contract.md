---
title: "Homelab Service Contract"
tags:
  - projects
modified: 2026-06-26
---

# Homelab Service Contract

**Type:** Architecture · **Updated:** 2026-06-21

A consistent structural rule set defining how every service in the homelab is deployed, isolated, addressed, and maintained.

## Core Principles

- One LXC per service
- Each service has a single responsibility
- Internal implementation details (ports, processes) are not part of external identity
- DNS is the primary human-facing identifier layer
- Proxmox defines lifecycle boundaries (create, snapshot, destroy)
- Configuration and intent are defined outside runtime systems

## Identity Model

| Layer | Identifier | Purpose |
|-------|-----------|---------|
| Machine | IP address | Ephemeral, operational only |
| Service | DNS name | Stable, human-facing |
| Runtime | Container name | Administrative reference |

## Exposure Rules

- Services should not expose internal ports directly unless necessary
- Prefer reverse proxy abstraction when multiple services or future expansion is likely
- Avoid embedding port numbers in documentation or user workflows

## Isolation Rules

- Each LXC is a bounded execution environment
- No shared runtime dependencies between services unless explicitly mounted
- Cross-service communication only through network interfaces, not filesystem coupling

## Operational Expectations

- Every service must be reproducible from a defined bootstrap procedure
- Every service must be snapshot-safe (no hidden state outside container)
- Every service must support clean teardown and rebuild without external dependencies
