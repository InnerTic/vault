Multi-Agent GGUF Runtime Switcher (MAGRS)
==========================================

One model file → many persona skins → dynamically switchable at inference time.
No fine-tuning. No extra models. Structured prompt + template routing.

## Files

  README.md       ← This file
  ARCH.md         — Architecture & core design
  META.md         — GGUF metadata schema extension
  ROUTING.md      — Switch mechanisms (CLI, inline, hidden prefix)
  IMPL.md         — Python switcher + llama.cpp wrapper
  PERSONAS.md     — Persona definitions (Monday, Analyst, Debugger)
  ADVANCED.md     — Auto-router, blending, token opt, hierarchical agents
  CHECKLIST.md    — Cross-off checklist
