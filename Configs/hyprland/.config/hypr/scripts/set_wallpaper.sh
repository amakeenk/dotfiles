#!/bin/bash

WALLPAPER_PATH="${HOME}/.config/hypr/images/wallpaper.jpg"
NEW_WALLPAPER_PATH="$(zenity --file-selection)"

magick "${NEW_WALLPAPER_PATH}" "${WALLPAPER_PATH}"

killall -9 hyprpaper; hyprpaper &

killall -9 waybar; waybar &
hyprctl reload

notify-send --expire-time=3000 "Фоновое изображение изменено" "Новое изображение: ${NEW_WALLPAPER_PATH}"
