#!/usr/bin/env bash
# Called by agent events, with the agent's inherited pane/session environment.
[[ -n ${ZELLIJ_SESSION_NAME:-} && ${ZELLIJ_PANE_ID:-} =~ ^[0-9]+$ ]] || exit 0
# Plain lifecycle words, or pre-rendered strings from pi's smart-tabs
# extension ("<icon> <model>", e.g. "⏳ gpt-5"), which the plugin renders
# verbatim because they don't match its `sub` status map.
case ${1:-} in
    idle|running|pending|done|error) ;;
    *\ * ) ;;
    *) exit 0 ;;
esac
status=${1//[\"\\]/}

# Do not read the hook's stdin, print output, or delay the agent on IPC failure.
timeout 2s zellij pipe --plugin smart-tabs --name pane_status -- \
    "{\"pane_id\":\"$ZELLIJ_PANE_ID\",\"status\":\"$status\"}" </dev/null >/dev/null 2>&1 || true
