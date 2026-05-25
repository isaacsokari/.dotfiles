---
name: pr-summary
description: Summarize branch changes for PR prep. Use when the user asks for a PR summary, pull request summary, or the old pr-summary command.
---

# PR Summary

Summarize the current branch against a base branch for PR prep.

Inputs:

- Optional base branch override. If the user does not provide one, resolve it with `git rev-parse --abbrev-ref origin/HEAD`.

Use this git context as the source of truth:

- Commits since base: `git log --oneline "$BASE"...HEAD`
- Diff stat since base: `git diff --stat "$BASE"...HEAD`
- Targeted diff for changed files: `git diff "$BASE"...HEAD`

Output rules:

- Focus on what changed and why it matters for a reviewer.
- Use past tense, e.g. `Added useHook1 and useHook2 hooks for <hook's purpose>.`
- Keep bullet points concise, one line each, with no sub-bullets.
- Ignore trivial churn unless it affects behavior, risk, or rollout.
- When referencing files, use the last meaningful name in the path without extension. If the filename is generic, such as `index`, `mod`, or `main`, use the parent directory name instead, such as `pages` for `src/pages/index.tsx`.
- Mention files only when they are essential to explain impact; omit otherwise.
- Aim for 3-6 bullets total across both sections. If there are more, collapse related changes into a single bullet rather than listing each separately.
- Output exactly two sections in this order: `Core`, then `Extra`.
- Under `Core`, only include the changes related to the core feature of the branch.
- Under `Extra`, include non-core changes. Omit this section entirely if there are none.
- Use concise `-` bullets under each section.

If the branch has no meaningful changes, say so briefly and do not pad the output.
