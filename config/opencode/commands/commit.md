---
description: Create a clean conventional commit
agent: build
subtask: true
---

Create a single semantic git commit for the current working tree.

Requirements:
- Review `git status`, diffs, and recent commit subjects before writing the message.
- Stage only files relevant to this change with explicit paths (`git add <path>`). Never use `git add -A`/`.`, and never stage files that may contain secrets.
- Subject: lowercase conventional commit (`type(scope): summary`), imperative mood, under ~72 chars, no trailing period. Pick the correct type (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, etc.).
- The summary must name the specific thing that changed. Avoid vague summaries like `fix bug`, `update code`, or `cleanup` — if it could describe a dozen other commits, rewrite it.
- Do not add a body except the *why* is non-obvious from the diff (blank line, wrap ~72 chars). For breaking changes, append `!` and add a `BREAKING CHANGE:` footer.
- Do not amend or push. If a pre-commit hook fails, fix the cause and make a new commit — never `--no-verify`.

After committing, report the final subject, commit hash, and `git status --short`.
