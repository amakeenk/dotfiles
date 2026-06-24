#!/bin/bash

VIDEO_DIR="$HOME/Videos/Recordings"
mkdir -p "$VIDEO_DIR"
VIDEO_FILE="$VIDEO_DIR/rec_$(date +%Y-%m-%d_%H-%M-%S).mp4"

if pgrep -x "wl-screenrec" > /dev/null; then
    menu_item_stop="🛑 Остановить запись видео"
    choice=$(echo -e "$menu_item_stop" | fuzzel --dmenu --width=25 --lines=1 --hide-prompt)
    if [ "$choice" = "$menu_item_stop" ]; then
        pkill -2 -x "wl-screenrec"
        notify-send "Запись экрана" "Запись остановлена и успешно сохранена" -i video-x-generic -a "wl-screenrec"
    fi
    exit 0
fi

menu_item_region_clipboard_only="📸 Снимок экрана: Выбранная область (только копирование)"
menu_item_region_save_file="📸 Снимок экрана: Выбранная область (сохранить в файл)"
menu_item_region_edit="📸 Снимок экрана: Выбранная область (редактировать)"
menu_item_output_clipboard_only="🖥️ Снимок экрана: Весь экран (только копирование)"
menu_item_output_save_file="🖥️ Снимок экрана: Весь экран (сохранить в файл)"
menu_item_output_edit="🖥️ Снимок экрана: Весь экран (редактировать)"
menu_item_rec_region="🎥 Запись видео: Выбранная область"
menu_item_rec_output="🎥 Запись видео: Весь экран"

menu="${menu_item_region_clipboard_only}\n\
${menu_item_region_save_file}\n\
${menu_item_region_edit}\n\
${menu_item_output_clipboard_only}\n\
${menu_item_output_save_file}\n\
${menu_item_output_edit}\n\
${menu_item_rec_region}\n\
${menu_item_rec_output}"

choice=$(echo -e "$menu" | fuzzel --dmenu --width=55 --lines=8 --hide-prompt)

case "$choice" in
  "${menu_item_region_clipboard_only}") hyprshot -m region --clipboard-only ;;
  "${menu_item_region_save_file}")      hyprshot -m region ;;
  "${menu_item_region_edit}")           hyprshot -m region --raw | swappy -f - ;;
  "${menu_item_output_clipboard_only}") hyprshot -m output --clipboard-only ;;
  "${menu_item_output_save_file}")      hyprshot -m output ;;
  "${menu_item_output_edit}")           hyprshot -m output --raw | swappy -f - ;;
  "${menu_item_rec_region}")
    GEOM=$(slurp -b "000000a0" -c "33ccffffe" -w 2)
    if [ -n "$GEOM" ]; then
        notify-send "Запись экрана" "Запись выделенной области началась..." -i video-single-user -a "wl-screenrec"
        wl-screenrec --geometry "$GEOM" --audio --audio-device default.monitor --filename "$VIDEO_FILE" & disown
    fi
    ;;
  "${menu_item_rec_output}")
    notify-send "Запись экрана" "Запись всего экрана началась..." -i video-single-user -a "wl-screenrec"
    wl-screenrec --audio --audio-device default.monitor --filename "$VIDEO_FILE" & disown
    ;;
esac
