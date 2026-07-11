#!/bin/bash

set -euo pipefail

WALLPAPER_PATH="${HOME}/.config/hypr/images/wallpaper.jpg"
NEW_WALLPAPER_PATH="$(zenity --file-selection)"

if [[ -z "${NEW_WALLPAPER_PATH}" ]]; then
    exit 0
fi

magick "${NEW_WALLPAPER_PATH}" "${WALLPAPER_PATH}"

killall -q hyprpaper 2>/dev/null || true
hyprpaper &

notify-send --expire-time=3000 "Фоновое изображение изменено" "Новое изображение: ${NEW_WALLPAPER_PATH}"
