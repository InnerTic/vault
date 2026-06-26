---
title: "Textgen Webui"
tags:
  - software
modified: 2026-06-26
  - ai
  - textgen-webui
---

# TextGen WebUI (oobabooga)

CUDA 12.4 (Debian) / 12.9 (CachyOS) · `/mnt/workspace/textgen/`

## Debian

### Python Version

Debian 13 Trixie ships **Python 3.13** by default. Textgen works with it — requirements include `audioop-lts<1.0; python_version >= "3.13"` for the 3.13 audioop removal.

```bash
sudo apt install python3 python3-venv
# Or: sudo apt install python3.11 python3.11-venv
```

### Clone

```bash
cd /mnt/workspace
git clone https://github.com/oobabooga/text-generation-webui textgen
cd textgen
```

### Create Venv

```bash
python3 -m venv venv
./venv/bin/python -m pip install --upgrade pip
```

### Install CUDA Requirements

```bash
./venv/bin/python -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124
./venv/bin/python -m pip install -r requirements/full/requirements.txt
```

Or use the auto-installer:

```bash
./start_linux.sh --listen
```

### Symlink Models

```bash
ln -s ~/Downloads/llm_models /mnt/workspace/textgen/user_data/models
```

### Launch

```bash
cd /mnt/workspace/textgen
./venv/bin/python server.py --listen --listen-port 7861 --api
```

### Notes

Textgen bundles its own `llama-server` binary inside the venv — the Debian `scripts/llama-server.sh` points to this instead of a standalone build.

## CachyOS

### Python Version

CachyOS `python3` is 3.14. Use an explicit older python:

```bash
sudo pacman -S python313  # recommended
sudo pacman -S python311  # alternative
```

### Clone

```bash
cd /mnt/workspace
git clone https://github.com/oobabooga/text-generation-webui textgen
cd textgen
```

### Create Venv

```bash
python3.13 -m venv venv
./venv/bin/python -m pip install --upgrade pip
```

### Install CUDA Requirements

```bash
./venv/bin/python -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu129
./venv/bin/python -m pip install -r requirements/full/requirements.txt
```

Or use auto-installer:

```bash
./start_linux.sh --listen
```

### Symlink Models

```bash
ln -s ~/Downloads/llm_models /mnt/workspace/textgen/user_data/models
```

### Launch

```bash
cd /mnt/workspace/textgen
./venv/bin/python server.py --listen --listen-port 7861 --api
```

## Related

- Launch script: `~/infra/textgen-start.sh`
- llama.cpp build: [[ai-tools/llama-setup]]


## P40/CUDA Fix

Textgen bundles `llama_cpp_binaries` compiled for sm_75+ only (Turing+). The Tesla P40 (Pascal, sm_61) causes a PDL kernel crash on model load.

**Fix:** Replace the bundled `libggml-cuda.so` with the local build's version:

```bash
BUNDLED_DIR="/mnt/workspace/textgen/venv/lib/python3.13/site-packages/llama_cpp_binaries/bin"
LOCAL_DIR="/mnt/workspace/llama.cpp/build/bin"
cp "$LOCAL_DIR/libggml-cuda.so.0" "$BUNDLED_DIR/libggml-cuda.so.0"
cp "$LOCAL_DIR/libggml-cuda.so" "$BUNDLED_DIR/libggml-cuda.so"
```

**Why:** The local llama.cpp build at `/mnt/workspace/llama.cpp/build/bin/` was compiled with `CMAKE_CUDA_ARCHITECTURES="61;86"`. Replacing just the CUDA library swaps in sm_61 support while keeping the rest of the bundled binaries intact.

**Fragile:** A textgen update will overwrite this. Re-apply after `pip install --upgrade llama-cpp-binaries`.
