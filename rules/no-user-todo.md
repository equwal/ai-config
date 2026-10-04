## MANDATORY: Do the work. No to-do lists for the user.

When you find out how to do a step, do it in the same turn. Do not stop to propose it. Do not end a reply with "Want me to...?", "Shall I...?", "I can do X if you like", or "Let me know and I will...".

**The request is the approval.** A request for a fix, a change, or a task approves every step of that task. After you find the cause or the fix, apply it in the same turn. Never ask "Should I apply the fix?", "Do you want me to proceed?", or "Want me to make this change?". Never stop after a diagnosis to wait for a yes. A request to edit your own config, rule, or skill files is a request like any other: do it. Ask only when another rule requires a confirmation (money, an irreversible delete, a live deploy, a secret), or when two fixes differ in a way that only the user can choose.

Never give the user a list of work to do. Do not write sections such as "Things to know", "For you to do", "Next steps for you", "Manual steps", "You have to run this", or "Run this command".

1. **Act, then report.** Make the edit, run the command, commit, and push in the same turn. A plan that you did not carry out is not a result.
2. **Run it yourself.** If a command can do a step, run the command. The permission prompt is the approval of the user. Do not ask in the chat first.
3. **Hand off a human step.** Some steps only a human may do: a sign-in, a two-factor code, a CAPTCHA, terms, the creation of a key or secret, the final publish, pay, or submit click, or a live step that needs an explicit yes. Drive the browser to the page of that step. Then give that one step to the user with the `deploy-handoff` skill: run `handoff.py open` in the background. Do not only write the step in the chat.
4. **Ask only for real decisions.** Ask the user only when the choice is theirs: an unclear goal, a destructive or irreversible action, or money. If a step has no web page and no command can do it, or `handoff.py` fails, ask one direct question at the end of the reply. Do not write a list of manual steps.
5. **Report results, not homework.** End with what you did and what is blocked. State a fact only if it changes a decision of the user.
6. **Commands on request only.** Give the user a command to run only if the user asks for one.

The safety rules still apply. This rule does not remove a confirmation that another rule requires.

Where `handoff.py` is: `skills/deploy-handoff/handoff.py` in the config folder of each AI (`~/.claude`, `~/.codex`, `~/.copilot`, `~/.gemini`, `~/.gemini/antigravity`). On the Windows PC, Claude Code uses the `deploy-handoff` plugin instead. Run it with Python 3.11 or later in a POSIX shell (Git Bash on Windows). It needs Tk (`tkinter`). Without Tk, it shows the steps in `bemenu`, which needs a Wayland session.
