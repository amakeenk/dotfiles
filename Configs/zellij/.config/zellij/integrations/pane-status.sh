#!/usr/bin/env bash
# Called by agent events, with the agent's inherited pane/session environment.
[[ -n ${ZELLIJ_SESSION_NAME:-} && ${ZELLIJ_PANE_ID:-} =~ ^[0-9]+$ ]] || exit 0
case ${1:-} in
    idle|running|pending|done|error) ;;
    *) exit 0 ;;
esac

# Do not read the hook's stdin, print output, or delay the agent on IPC failure.
timeout 2s zellij pipe --plugin smart-tabs --name pane_status -- \
    "{\"pane_id\":\"$ZELLIJ_PANE_ID\",\"status\":\"$1\"}" </dev/null >/dev/null 2>&1 || true
