#!/bin/bash

set -euo pipefail

CONFIG_PATH="${HOME}/.config/hyprlax/hyprlax.toml"

# Avoid running two wallpaper daemons on top of each other.
killall -q hyprpaper 2>/dev/null || true

exec hyprlax \
  --compositor hyprland \
  --config "${CONFIG_PATH}"
