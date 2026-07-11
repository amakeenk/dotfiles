#!/bin/bash

set -euo pipefail

CONFIG_PATH="${HOME}/.config/hyprlax/hyprlax.toml"
LOG_PATH="${XDG_RUNTIME_DIR:-/tmp}/hyprlax-autostart.log"

log() {
    printf '%s %s\n' "$(date '+%F %T')" "$*" >>"${LOG_PATH}"
}

# Avoid running two wallpaper daemons on top of each other.
killall -q hyprpaper 2>/dev/null || true

cleanup_hyprlax() {
    killall -q hyprlax 2>/dev/null || true
    sleep 0.5

    if pgrep -x hyprlax >/dev/null; then
        log "hyprlax ignored SIGTERM; killing it"
        killall -9 -q hyprlax 2>/dev/null || true
        sleep 0.2
    fi

    if ! pgrep -x hyprlax >/dev/null; then
        rm -f -- "${XDG_RUNTIME_DIR:-/tmp}/hyprlax-${USER}-"*.sock
    fi
}

wait_for_monitor() {
    # Hyprland may execute autostart commands before the monitor is fully ready.
    for _ in {1..100}; do
        if hyprctl monitors -j 2>/dev/null | grep -q '"name"'; then
            sleep 1
            return 0
        fi

        sleep 0.1
    done

    return 1
}

start_hyprlax() {
    log "starting hyprlax"
    hyprlax \
        --compositor hyprland \
        --config "${CONFIG_PATH}" >>"${LOG_PATH}" 2>&1 &
}

hyprlax_layer_exists() {
    hyprctl layers 2>/dev/null | grep -q 'namespace: hyprlax'
}

cleanup_hyprlax
wait_for_monitor || log "monitor was not detected before timeout"
start_hyprlax

while true; do
    sleep 3

    if ! pgrep -x hyprlax >/dev/null; then
        log "hyprlax process is missing; restarting"
        wait_for_monitor || true
        start_hyprlax
        continue
    fi

    if ! hyprlax_layer_exists; then
        log "hyprlax layer is missing; restarting"
        cleanup_hyprlax
        wait_for_monitor || true
        start_hyprlax
    fi
done
