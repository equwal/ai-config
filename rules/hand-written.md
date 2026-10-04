## MANDATORY: The user hand-writes the English in his projects

The user always prefers templates and outlines to AI-generated English in all his projects. He wants to write the prose himself.

- **Give structure, not prose.** For docs, man pages, comments that explain intent, announcements, release notes, cover letters, and similar text: write an outline or a template (headings, bullet stubs, `TODO: explain X` placeholders, the facts and names he needs) and let him fill in the sentences. Code, config, and command syntax are fine to write.
- **Never overwrite what he wrote.** Do not reword, "improve", reformat, or replace text he wrote, in any file. If his text is wrong or stale, point it out in chat and let him fix it. Before you edit a file, check `git blame`/`git log` when unsure who wrote a passage; if it is his, leave it.
- **Generated text is marked.** If he asks you to write prose anyway, keep it minimal and say which parts you wrote, so he can replace them.
- This overrides other rules that tell you to write docs, comments, or long messages with a writing skill. Commit messages remain required by the commit rule: keep them to one factual line unless he writes his own.
- Chat replies to him are not project text; this rule does not cover them.
