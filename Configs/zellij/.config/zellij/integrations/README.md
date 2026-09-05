# Smart tabs agent events

Zellij downloads the pinned stable WASM release from the URL in `config.kdl`.
There is one alias and one background instance per new Zellij session. Existing
sessions created before the alias was added need a new session to use it.

Installed entry points (symlinks to the files in this directory):

- `~/.codex/hooks.json` → `codex-hooks.json`
- `~/.config/opencode/plugins/smart-tabs.js` → `opencode-smart-tabs.js`
- `~/.pi/agent/extensions/smart-tabs.ts` → `pi-smart-tabs.ts`

The agent configuration directories are not managed by Tuckr. Preserve these
symlinks when moving the repository, or recreate them with the new source path.
`pane-status.sh` sends only `pane_status` messages using the agent's inherited
`ZELLIJ_PANE_ID` and session environment. It is silent outside Zellij and bounds
IPC waits to two seconds. Program/CWD detection belongs entirely to smart-tabs.

| Agent | Events and states |
| --- | --- |
| Codex 0.153.4 | `UserPromptSubmit`, `PreToolUse` → running; `PostToolUse`, `PermissionRequest` → pending; `Stop` → done; `SessionStart`, `SessionEnd`, `Interrupt` → idle |
| OpenCode 1.14.24 | `session.status`: busy → running, retry → pending, idle → done; `session.error` → error, retained through the subsequent idle event |
| Pi 0.84.4 | `agent_start`, `turn_start` → running; `turn_end` → pending; `agent_settled` → done/error/idle according to the final assistant stop reason; session start/shutdown → idle |

Codex's eight hooks were reviewed and trusted using its built-in hook browser;
trust hashes are stored by Codex in `~/.codex/config.toml`. Changed hook
definitions require review through `/hooks`. No dedicated response-error event
is documented for this Codex version, so none is invented here. Another Stop
hook can request continuation; the next prompt/tool event restores running.

OpenCode filters out child sessions and serializes event handling. The plugin
supports the local CLI process that owns a Zellij pane. A separately started
server or remote/desktop client has no reliable originating terminal pane ID.
Pi waits for `agent_settled`, since `agent_end` can precede automatic retries.
No absent agents are installed; Claude Code and oh-my-pi were not found.

The requested template uses the first terminal pane of each tab, as defined by
smart-tabs. Status from a different split pane is stored but is not the top-level
`status` variable. The Node launcher is skipped so the installed
`node /path/to/opencode` command displays as `opencode`; other Node scripts
therefore display their script basename too.

Manual rename entry points remain `Alt+r`, tab-mode `r`, and tmux-mode `,`.
Enter reaffirms manual mode after editing. Esc retains UndoRenameTab and tab mode,
then toggles manual → managed to force a fresh computed name. This handles the
plugin restoring managed mode as soon as TabNameInput clears a name.

Verified on 2026-09-05 with Zellij 0.45.1 and release v0.2.4:

- Native Zellij configuration check and shell/JavaScript parsing pass.
- WASM downloaded by Zellij, permissions granted, one smart-tabs instance.
- All five pipe states render correctly; idle removes the status suffix.
- CWD changes update the name; shell has no extra separator.
- Actual hx, Pi, Codex, and OpenCode startup names were checked.
- `tmp · opencode ⏳` → `tmp · opencode ✅` → `tmp · opencode` passes.
- Manual name survives a CWD change; Esc restores the automatic name.
- Installed Pi loader accepts the extension; OpenCode logs plugin loading;
  Codex lists all eight hooks as active.
- Handler tests cover event order, retries, errors, child-session filtering,
  originating pane IDs, and silent behavior outside Zellij.

No model requests were sent for testing. Agent event handlers were exercised
with synthetic lifecycle events; full provider-backed turns were not tested.

References: [smart-tabs README](https://github.com/YesYouKenSpace/zellij-smart-tabs),
[Codex hooks](https://learn.chatgpt.com/docs/hooks),
[OpenCode plugins](https://opencode.ai/docs/plugins/).
Pi's installed version documentation is `/usr/lib/node_modules/pi/docs/extensions.md`.
