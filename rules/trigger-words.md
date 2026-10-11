## Trigger words

- 'PUSH' = commit and push now, without asking again.
- 'DEPLOY' = build, deploy, and verify live, without asking again. Where a DEPLOY pipeline rule exists (Claude Code: rules/deploy-handoff.md), run that pipeline.
- 'MERGE' = merge into the EXISTING file, config, or addon. Never create a parallel copy.
- If a task naturally ends in push/deploy/install, carry it through. Do not stop and hand the last step back to me.
