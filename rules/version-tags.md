## MANDATORY: Mark milestones with version tags

The user marks meaningful points in a project's development with git version tags.

- Tag a milestone, not every commit: a working feature set, a release, a deploy, a finished phase, or a safe point before a risky change.
- Use the project's existing tag scheme. If it has none, use semver `vMAJOR.MINOR.PATCH`, starting at `v0.1.0`.
- Tag a commit whose tests pass. Use an annotated tag with a one-line factual message: `git tag -a vX.Y.Z -m "<what this point is>"`.
- Push the tag with the branch: `git push origin vX.Y.Z`.
- Never move or delete an existing tag.
