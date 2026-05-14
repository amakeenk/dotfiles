#!/bin/bash

DOTFILES_DIR="."

APPS_LIST=(
    "bash"
    "bat"
    "fastfetch"
    "fuzzel"
    "helix"
    "hyprland"
    "kitty"
    "matugen"
    "neovim"
    "starship"
    "swaync"
    "waybar"
    "yazi"
    "zed"
    "zellij"
)

ARG=$1

if ! command -v stow >/dev/null 2>&1; then
  echo "Ошибка: команда 'stow' не найдена. Установите её и попробуйте снова."
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Использование: $0 <app_name|all>"
  exit 1
fi

check_app() {
  local app=$1
  [ -d "$DOTFILES_DIR/$app" ]
}

install_app() {
  local app=$1
  check_app "$app"
  if [ $? -eq 0 ]; then
    echo "Установка конфигурации для $app"
    stow -R -v -t "$HOME" "$app"
  else
    echo "Конфигурация для '$app' не найдена."
  fi
}

if [ "$ARG" == "all" ]; then
  for app in "${APPS_LIST[@]}"; do
    install_app "$app"
  done
else
  install_app "$ARG"
fi
