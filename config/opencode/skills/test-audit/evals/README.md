# Behavioral evaluations

`evals.json` defines three tasks and their observable success criteria. Each
fixture is a standalone Node.js repository; it needs no package installation.
Some tests are intentionally weak or failing so the audit has something to find.

For each task:

1. Copy the named fixture into an isolated directory and initialize a local Git
   baseline, so review-only edits and production changes can be inspected.
2. Give a fresh coding agent the skill and the task's `prompt`. Let it inspect,
   edit when requested, and run the commands in the fixture's `AGENTS.md`.
3. Save its transcript, final report, and diff. Grade against `assertions` using
   both the transcript and resulting files, not just the agent's claims.
4. Compare with a fresh run using the original skill or no skill. Keep the model,
   tools, task, and starting fixture identical.

For `duplicate-proof`, verify the keeper rejects a mutation that returns an
unrounded quote. For `regression-authoring`, copy the final tests into another
isolated directory with the original `retry.mjs` and confirm the regression
fails for the intended reason. Run the repaired implementation independently
for success on attempt three and exhaustion at the configured limit.

These cases check authoring and focused audit behavior. They do not establish
automatic trigger accuracy or exhaustive campaign performance.
