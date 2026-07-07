---
title: "IMPL"
tags:
  - projects
modified: 2026-06-26
---

# "IMPL"

Python Implementation
=====================

## AgentSwitcher (core)

  class AgentSwitcher:
      def __init__(self, gguf_kv):
          self.kv = gguf_kv
          self.default = gguf_kv.get("agent.default", "monday")

      def resolve(self, user_input):
          if user_input.startswith("/agent"):
              return user_input.split()[1]
          return self.default

      def get_system_prompt(self, agent_name):
          key = f"agent.{agent_name}.system_prompt"
          return self.kv.get(key, self.kv.get("agent.monday.system_prompt"))

## llama.cpp wrapper

  class MultiAgentLLM:
      def __init__(self, model_path, gguf_kv):
          self.llm = Llama(model_path=model_path)
          self.switcher = AgentSwitcher(gguf_kv)

      def chat(self, messages, user_input):
          agent = self.switcher.resolve(user_input)
          system = self.switcher.get_system_prompt(agent)
          full_messages = [{"role": "system", "content": system}] + messages
          return self.llm.create_chat_completion(messages=full_messages)

## GGUF patch helper

  def add_agent(metadata, name, prompt, style):
      metadata[f"agent.{name}.system_prompt"] = prompt
      metadata[f"agent.{name}.style"] = style

  def build_multi_agent_metadata(agent_json):
      return {
          "agent.default": "monday",
          "agent.monday.system_prompt": "...",
          "agent.analyst.system_prompt": "...",
          "agent.debugger.system_prompt": "...",
      }
