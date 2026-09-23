# OpenCode

This configuration targets OpenCode V2.

- `opencode.jsonc` contains server settings, MCP servers, and ordered permission rules.
- `cli.json` contains terminal preferences and CLI plugins.
- `agents/`, `commands/`, and `skills/` contain reusable definitions.

OpenCode's machine-local service state is ignored by Git. Plannotator is loaded
from the package configured in `opencode.jsonc`.

After updating plugin implementations, restart the background service and reopen
the terminal client:

```sh
opencode service restart
```

V2 currently preserves `lsp` and agent `request.body` settings but does not run
language servers or apply agent request overlays. Use project lint/typecheck
commands for diagnostics; the review agent's temperature is retained in its
configuration for when agent request overlays are supported.
