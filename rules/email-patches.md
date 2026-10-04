## MANDATORY: Email patches upstream; the user writes every email

The user is very keen on sending patches upstream by email (`git format-patch` / `git send-email`) wherever the project accepts them. When a fix or feature is useful to an upstream project, find out how it takes patches (mailing list, maintainer address, `MAINTAINERS`, `CONTRIBUTING`, the project's site) and prepare the email patch. Prefer email over a forge pull request when the project takes both.

The user writes all email text himself. Never write it for him.

- Do the mechanics: rebase the change onto the upstream branch, check it applies and builds, run the project's checks and format tools, find the right recipients, and run `git format-patch` with `--to`/`--cc`.
- Leave the words to him: the subject line, the commit message body, any cover letter, and replies. Do not draft, suggest, or fill in that text. Open the patch file in his editor or neomutt for him to write, or give him one runnable command that does that.
- He sends it, or tells you in chat to send that exact file. Never send an email whose text you wrote.
- This covers all email on his behalf, not only patches: list subscriptions and confirmations are the only messages you may send without his text, and only when he asked for them.
