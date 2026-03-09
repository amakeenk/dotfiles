#!/bin/bash

menu_item_region_clipboard_only="Выбранная область (только копирование)"
menu_item_region_save_file="Выбранная область (сохранить в файл)"
menu_item_region_edit="Выбранная область (редактировать)"
menu_item_output_clipboard_only="Весь экран (только копирование)"
menu_item_output_save_file="Весь экран (сохранить в файл)"
menu_item_output_edit="Весь экран (редактировать)"

menu="${menu_item_region_clipboard_only}\\n\
${menu_item_region_save_file}\\n\
${menu_item_region_edit}\\n\
${menu_item_output_clipboard_only}\\n\
${menu_item_output_save_file}\\n\
${menu_item_output_edit}"

choice=$(echo -e "$menu" | fuzzel --dmenu)

case "$choice" in
  "${menu_item_region_clipboard_only}") hyprshot -m region --clipboard-only ;;
  "${menu_item_region_save_file}")      hyprshot -m region ;;
  "${menu_item_region_edit}")           hyprshot -m region --raw | swappy -f - ;;
  "${menu_item_output_clipboard_only}") hyprshot -m output --clipboard-only ;;
  "${menu_item_output_save_file}")      hyprshot -m output ;;
  "${menu_item_output_edit}")           hyprshot -m output --raw | swappy -f - ;;
esac
