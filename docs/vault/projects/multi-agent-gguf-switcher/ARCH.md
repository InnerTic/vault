Architecture
============

One model file, multiple personas, runtime-switchable system prompt.

Structure
---------

  model.gguf
      |
  Runtime Switcher Layer
      |
      ├── Monday (default reasoning agent)
      ├── Analyst (deep inspection / forensic)
      └── Debugger (execution-first / procedural)

All personas share: same weights, tokenizer, chat template.
Only system prompt segment changes dynamically.

Runtime flow
------------

  User input
      ↓
  Agent selector parses intent
      ↓
  Chooses persona (monday / analyst / debugger)
      ↓
  Injects persona system prompt
      ↓
  Calls llama.cpp
      ↓
  Response

Key property: deterministic routing, no fine-tuning required.
