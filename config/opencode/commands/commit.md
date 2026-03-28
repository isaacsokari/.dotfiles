---
description: Create a clean conventional commit
agent: plan
subtask: true
---

Create a single git commit for the current working tree.

Requirements:
- Review `git status`, staged/unstaged diffs, and recent commit subjects before writing the message.
- Stage relevant files for this change only. Do not include unrelated edits.
- Use a one-line conventional commit subject in lowercase (`type(scope): summary` or `type: summary`).
- Prefer the smallest accurate type (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, etc.).
- The summary must name the specific thing that changed — not just what was done to it. Avoid vague summaries like `fix bug`, `update code`, `refactor`, `misc changes`, or `cleanup`. Instead of "fix validation", write "fix missing required-field check in login form".
- If the summary would be equally true for a dozen other commits, it is too vague — make it more specific.
- Do not amend existing commits unless explicitly requested.
- Do not push.

After committing, report:
- Final commit subject
- Commit hash
- `git status --short` result
