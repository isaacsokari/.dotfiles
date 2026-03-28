---
description: Summarize branch changes for a PR
agent: plan
subtask: true
---

Summarize the current branch against a base branch for PR prep.

Arguments:
- `$1` = optional base branch override; default is generated below

Resolved inputs:
- Base branch: `${1:-$(git rev-parse --abbrev-ref origin/HEAD)}`

Use this git context as the source of truth.

Commits since base:
!`BASE=${1:-$(git rev-parse --abbrev-ref origin/HEAD)}; git log --oneline "$BASE"...HEAD`

Diff stat since base:
!`BASE=${1:-$(git rev-parse --abbrev-ref origin/HEAD)}; git diff --stat "$BASE"...HEAD`

Targeted diff for changed files:
!`BASE=${1:-$(git rev-parse --abbrev-ref origin/HEAD)}; git diff "$BASE"...HEAD`

Output rules:
- Focus on what changed and why it matters for a reviewer.
- Use past tense, e.g.
  - Added useHook1 and useHook2 hooks for <hook's purpose>.
  - Added ComponentOne component to <component's purpose>.
- Keep bullet points concise — one line each, no sub-bullets.
- Ignore trivial churn unless it affects behavior, risk, or rollout.
- When referencing files, use the last meaningful name in the path without extension — if the filename is generic (e.g. `index`, `mod`, `main`), use the parent directory name instead (e.g. `pages` for `src/pages/index.tsx`).
- Mention files only when they are essential to explain impact; omit otherwise.
- Aim for 3–6 bullets total across both sections. If there are more, collapse related changes into a single bullet rather than listing each separately.

- Output exactly two sections in this order: `Core`, then `Extra`
- Under `Core`, only include the changes related to the core feature of the branch.
- Under `Extra`, include non-core changes. Omit this section entirely if there are none.
- Use concise `-` bullets under each section.

If the branch has no meaningful changes, say so briefly and do not pad the output.
