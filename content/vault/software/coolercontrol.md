---
title: "CoolerControl"
tags:
  - software
  - cooling
  - hardware
modified: 2026-07-02
---

# CoolerControl

Fan/pump control daemon + GUI for Linux. Detects `hwmon/sysfs` and `liquidctl` devices, provides Web UI and desktop app.

## Packages

- `coolercontrold` — system daemon (required)
- `coolercontrol` — desktop app (optional, or use Web UI)

Optional deps: `liquidctl` (AIOs/coolers), `lm_sensors` (hwmon support)

## Install (Debian)

```bash
# coolercontrold (daemon) + coolercontrol (desktop app)
sudo apt install coolercontrold coolercontrol
# Optional deps for better hardware support
sudo apt install liquidctl lm-sensors
```

Works on Debian 13 Trixie — daemon detects hwmon devices, desktop GUI applies fan graphs that function correctly. Fan control takes effect immediately.

## Usage

1. Check [[hardware-support]] — verify devices are detected, load required kernel modules
2. Create a Profile (Fan Profiles → Graph Profile), set temp sensor + curve
3. Assign Profile to fan channels (Controls Page or per-fan settings)
4. One Profile can be reused across multiple fans

## Features

- GUI with dashboards, system daemon runs in background
- Control devices based on any temp sensor or combination
- Auto-detection of hwmon/sysfs and liquidctl devices
- GPU fan control (NVIDIA + AMD)
- Profiles: Fixed, Graph, Mix, Overlay
- Custom Sensors from files or sensor combos
- System-wide cooling Modes
- Alerts for temp/fan anomalies
- REST API, headless Web UI, remote access

## References

- [Getting Started](https://docs.coolercontrol.org/getting-started.html)
- `hwmon` sysfs at `/sys/class/hwmon/hwmon*/`
- [[translation-pipeline]] cooling notes
