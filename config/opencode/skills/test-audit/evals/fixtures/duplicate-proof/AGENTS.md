# Pricing fixture

This is a standalone Node.js module with no dependencies or build step.
Run tests with `node --test test/*.test.mjs` and check whitespace with
`git diff --check`. There are no other required gates.

Only `quote` is public. `__testRound` was added for the private rounding test;
there are no external consumers or dynamic loaders. The boundary test covers
the same rounding input through the real quote path. Work only in this fixture.
