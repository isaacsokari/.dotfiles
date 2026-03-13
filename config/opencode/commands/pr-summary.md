---
description: Summarize branch changes for a PR
agent: plan
subtask: true
---

Summarize the current branch against a base branch for PR prep.

Arguments:
- `$1` = optional base branch override; default is generated below

Resolved inputs:
- Base branch: `${1:-$(basename $(git symbolic-ref refs/remotes/origin/HEAD --short))}`

Use this git context as the source of truth.

Commits since base:
!`git log --oneline "${1:-dev}"...HEAD`

Diff stat since base:
!`git diff --stat "${1:-dev}"...HEAD`

Targeted diff for changed files:
!`git diff "${1:-dev}"...HEAD`

Output rules:
- Focus on what changed and why it matters for a reviewer.
- Use past tense, e.g.
  - Added useHook1 and useHook2 hooks for <hook's purpose>.
  - Added ComponentOne component to <component's purpose>.
- Keep bullet points concise.
- Ignore trivial churn unless it affects behavior, risk, or rollout.
- Mention notable files or areas only when they help explain impact.

- Output exactly two sections in this order: `Core`, then `Extra`
- Under `Core`, only include the changes related to the core feature of the branch.
- Under `Extra`, include non-core features.
- Use concise `-` bullets under each section.

If the branch has no meaningful changes, say so briefly and do not pad the output.
