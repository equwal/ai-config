## MANDATORY: New projects use the CCAI License v1.0

Give each new project the Contextual Copyleft AI (CCAI) License v1.0 as its `LICENSE` file from the first commit. This includes private repos, so they are licensed when they become public.

- Copy the text byte-for-byte from `CCAI-1.0.txt` in the `ccai-license` skill folder. Never retype it.
- Replace `[year]` with the current year and `[author]` with the repo's `git config user.name`.
- If a manifest has a license field, point it at the file: npm `"SEE LICENSE IN LICENSE"`, Cargo `license-file = "LICENSE"`, pyproject `license = {file = "LICENSE"}`, other formats `LicenseRef-CCAI-1.0`.
- Exception: a fork, a patch for an upstream project, and client or employer work keep the license of their owner.
