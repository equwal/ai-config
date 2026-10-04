---
name: skill-learning
description: Turn hard-won experience into reusable skills, Hermes Agent style. Use at the end of a task that took many steps, hit errors before it worked, or got a correction from the user; and whenever a skill you followed turned out wrong or outdated. Creates a new SKILL.md or patches an existing one so the next session does the job faster.
---

# Skill learning

Hermes Agent (Nous Research) improves itself in a closed loop: after hard work
it writes a skill, and when a skill fails in use it fixes the skill. This skill
gives the same loop to every AI on this machine.

## When to run

Run this check at the end of a task, after the work is verified and committed.
Save a skill only if one of these is true:

1. The task took about 5 or more tool calls and the steps will come back.
2. You hit errors or dead ends, then found the path that works.
3. The user corrected your approach.
4. You found a non-obvious workflow, command sequence, or tool quirk.
5. You followed an existing skill and it was wrong, incomplete, or outdated.

Skip it if none is true. Most tasks need no skill. Never save a one-off
answer, project facts that the code already shows, or a step a permission
check denied.

## Patch before you create

1. List the skill folders (see "Where skills live") and read the names and
   descriptions.
2. If a skill covers the topic, patch it: fix the wrong step, add the gotcha,
   update the command. Keep the rest.
3. Only if nothing covers it, create a new skill.

## Write the skill

Folder: `<skills folder>/<kebab-case-name>/SKILL.md`. Format:

```markdown
---
name: <kebab-case-name>
description: <what it does and WHEN to use it, with the trigger words a future
  request would contain. One or two sentences.>
---

# <Title>

## When to use
## Steps            (numbered, with the exact commands that worked)
## Gotchas          (the errors you hit and how you got past them)
## Verify           (the command that proves it worked)
```

Rules for the content:

- Write steps that worked, not steps you tried. Keep it under about 150 lines.
- Use exact commands, paths, and flags. Refer to code by symbol name, not by
  line number.
- No secrets, tokens, keys, passwords, or personal data. Use environment
  variable names instead.
- A skill never weakens a rule in CLAUDE.md, AGENTS.md,
  copilot-instructions.md, or GEMINI.md. If a skill and a rule conflict, the
  rule wins; fix the skill.
- Write in plain English: short sentences, active voice.

## Where skills live

Each AI reads its own folder. Write the skill to your own folder, then copy
the same `<name>/` folder to the other folders on this computer, so all AIs
learn it:

| AI | Skills folder |
|---|---|
| Claude Code | `~/.claude/skills/` |
| Codex | `~/.codex/skills/` |
| Copilot CLI | `~/.copilot/skills/` |
| Antigravity | `~/.gemini/skills/` and `~/.gemini/antigravity/skills/` |

If a skill is specific to one AI's tools, keep it only in that AI's folder.

## Finish

1. Commit the new or patched skill in each config folder that changed (each
   is a git repo), then push.
2. Tell the user in one line: the skill name, created or patched, and why.
