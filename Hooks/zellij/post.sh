#!/usr/bin/env bash

set -u

hook_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd -- "$hook_dir/../.." && pwd)
integration_dir="$repo_root/Configs/zellij/.config/zellij/integrations"

link_if_agent_present() {
    local agent=$1
    local source=$2
    local target=$3

    if [[ ! -e "$source" ]]; then
        printf 'tuckr zellij hook: missing integration source: %s\n' "$source" >&2
        return 1
    fi

    if ! command -v "$agent" >/dev/null 2>&1 && [[ ! -d "${target%/*}" ]]; then
        printf 'tuckr zellij hook: %s not found; skipping %s\n' "$agent" "$target"
        return 0
    fi

    mkdir -p "${target%/*}"

    if [[ -L "$target" ]]; then
        if [[ $(readlink -f -- "$target") == "$source" ]]; then
            printf 'tuckr zellij hook: already linked %s\n' "$target"
            return 0
        fi
        printf 'tuckr zellij hook: refusing to replace symlink: %s\n' "$target" >&2
        return 1
    fi

    if [[ -e "$target" ]]; then
        printf 'tuckr zellij hook: refusing to replace existing file: %s\n' "$target" >&2
        return 1
    fi

    ln -s -- "$source" "$target"
    printf 'tuckr zellij hook: linked %s\n' "$target"
}

link_if_agent_present codex \
    "$integration_dir/codex-hooks.json" \
    "$HOME/.codex/hooks.json"

link_if_agent_present opencode \
    "$integration_dir/opencode-smart-tabs.js" \
    "$HOME/.config/opencode/plugins/smart-tabs.js"

link_if_agent_present pi \
    "$integration_dir/pi-smart-tabs.ts" \
    "$HOME/.pi/agent/extensions/smart-tabs.ts"
