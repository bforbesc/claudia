---
name: switch
description: Switch Claude Code to a different account by logging out and prompting login. Use this skill whenever the user says /switch, "switch account", "change account", "log out", "use other account", or wants to switch between personal and work accounts without passing any context.
allowed-tools: Bash
---

Switch accounts immediately — no context summary, no extra steps.

1. Tell the user: "Switching accounts — a browser window will open to authenticate."
2. Run:
   ```bash
   claude auth logout && claude auth login
   ```
3. Confirm the new account is active.
