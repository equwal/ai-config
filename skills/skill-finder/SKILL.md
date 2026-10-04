---
name: skill-finder
description: Use the skill.fish registry to search for, add, and manage AI agent skills when you need a new capability.
---

# Skill Finder

You have access to the `skillfish` CLI, which allows you to install and manage AI agent skills from GitHub repositories. Use it whenever the user asks for a capability you don't have, or if you need a specific tool.

## Usage

You can run `npx --yes skillfish <command>` via your terminal execution tools.

Commands:
- `search <query>`: Search for skills in the registry.
- `add <owner/repo> [skill-name]`: Install a skill from a GitHub repository. If you don't know the specific skill name, run `npx --yes skillfish add <owner/repo>` to see the list of available skills in that repository.
- `list`: List installed skills across all detected agents.
- `remove [skill]`: Remove an installed skill.
- `update`: Check for and apply updates to installed skills.

Whenever the user asks you to use skill finder or add a skill from skill.fish, use the commands above to find and install the requested capabilities.
