# Retry fixture

This module's public boundary is `sendWithRetry`. Callers supply the transport
interface because production uses several transports; this is not a test hook.
`maxAttempts` includes the initial attempt. On exhaustion, rethrow the last
transport error. The default allows three attempts.

Run `node --test test/*.test.mjs` and `git diff --check`. There are no dependencies,
build steps, or other required gates. Work only in this fixture.
