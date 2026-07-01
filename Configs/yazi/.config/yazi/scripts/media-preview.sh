#!/usr/bin/env bash

set -euo pipefail

file_path="${1:?missing file path}"
preview_width="${2:-80}"
preview_height="${3:-24}"
image_block_height=0
preview_colors=1

if [[ -n "${NO_COLOR:-}" || "${TERM:-}" == "dumb" ]]; then
    preview_colors=0
fi

detect_mime() {
    file -Lb --mime-type -- "$file_path" 2>/dev/null || true
}

is_image_mime() {
    local mime_type
    mime_type="$(detect_mime)"
    [[ "$mime_type" == image/* ]]
}

is_video_mime() {
    local mime_type
    mime_type="$(detect_mime)"
    [[ "$mime_type" == video/* ]]
}

clamp() {
    local value="$1"
    local min_value="$2"
    local max_value="$3"

    if (( value < min_value )); then
        printf '%s\n' "$min_value"
    elif (( value > max_value )); then
        printf '%s\n' "$max_value"
    else
        printf '%s\n' "$value"
    fi
}

render_image() {
    local image_height

    if (( preview_height < 12 )); then
        image_height=$(( preview_height / 2 ))
    else
        image_height=$(( preview_height * 45 / 100 ))
    fi

    image_height="$(clamp "$image_height" 1 "$preview_height")"
    image_block_height=$(( image_height + 1 ))

    if magick "$file_path" -auto-orient -thumbnail "${preview_width}x${image_height}>" png:- 2>/dev/null \
        | viu --static --blocks --width "$preview_width" --height "$image_height" - 2>/dev/null; then
        :
    else
        viu --static --blocks --width "$preview_width" --height "$image_height" -- "$file_path" 2>/dev/null || true
    fi

    printf '\n'
}

render_video_frame() {
    local image_height
    local frame_rendered=0

    if (( preview_height < 12 )); then
        image_height=$(( preview_height / 2 ))
    else
        image_height=$(( preview_height * 45 / 100 ))
    fi

    image_height="$(clamp "$image_height" 1 "$preview_height")"
    image_block_height=$(( image_height + 1 ))

    if ffmpeg -loglevel error -y -ss 1 -i "$file_path" -frames:v 1 -f image2pipe -vcodec png - 2>/dev/null \
        | viu --static --blocks --width "$preview_width" --height "$image_height" - 2>/dev/null; then
        frame_rendered=1
    elif ffmpeg -loglevel error -y -i "$file_path" -frames:v 1 -f image2pipe -vcodec png - 2>/dev/null \
        | viu --static --blocks --width "$preview_width" --height "$image_height" - 2>/dev/null; then
        frame_rendered=1
    fi

    if (( frame_rendered == 1 )); then
        printf '\n'
    else
        image_block_height=0
    fi
}

render_fallback() {
    local mime_type file_size

    mime_type="$(detect_mime)"
    if [[ -z "$mime_type" ]]; then
        mime_type="unknown"
    fi
    file_size="$(stat -Lc '%s bytes' -- "$file_path" 2>/dev/null || printf 'unknown')"

    if (( preview_colors == 1 )); then
        printf '\033[1;36mGeneral\033[0m\n'
        printf '\033[38;5;245mFormat:\033[0m %s\n' "$mime_type"
        printf '\033[38;5;245mFile size:\033[0m %s\n' "$file_size"
    else
        printf 'General\n'
        printf 'Format: %s\n' "$mime_type"
        printf 'File size: %s\n' "$file_size"
    fi
}

render_mediainfo() {
    mediainfo -- "$file_path" 2>/dev/null | awk -v use_color="$preview_colors" '
        function trim(value) {
            sub(/^[[:space:]]+/, "", value)
            sub(/[[:space:]]+$/, "", value)
            return value
        }

        function color(code, text) {
            return use_color ? sprintf("%c[%sm%s%c[0m", 27, code, text, 27) : text
        }

        function base_section_name(name) {
            sub(/ #[0-9]+$/, "", name)
            return name
        }

        function wanted(label) {
            return label == "Format" ||
                label == "File size" ||
                label == "File last modification date" ||
                label == "Width" ||
                label == "Height" ||
                label == "Display aspect ratio" ||
                label == "Color space" ||
                label == "Chroma subsampling" ||
                label == "Bit depth" ||
                label == "Compression mode" ||
                label == "Compression" ||
                label == "Stream size" ||
                label == "Duration" ||
                label == "Bit rate" ||
                label == "Overall bit rate" ||
                label == "Frame rate" ||
                label == "Frame count" ||
                label == "Writing library" ||
                label == "Writing application" ||
                label == "Encoded library" ||
                label == "Channel(s)" ||
                label == "Sampling rate" ||
                label == "Title" ||
                label == "Album" ||
                label == "Track name" ||
                label == "Performer" ||
                label == "Composer" ||
                label == "Genre" ||
                label == "Recorded date" ||
                label == "Encoded date" ||
                label == "Tagged date" ||
                label == "Description" ||
                label == "Comment"
        }

        function emit_section(name) {
            if (printed_sections[name]) {
                return
            }

            if (printed_any) {
                print ""
            }

            print color("1;36", name)
            printed_sections[name] = 1
            printed_any = 1
        }

        $0 ~ /^(General|Image|Video|Audio|Text|Menu)( #[0-9]+)?$/ {
            section = $0
            next
        }

        index($0, ":") {
            if (section == "") {
                next
            }

            normalized = base_section_name(section)
            if (section ~ / #[2-9][0-9]*$/) {
                next
            }

            label = trim(substr($0, 1, index($0, ":") - 1))
            value = trim(substr($0, index($0, ":") + 1))

            if (!wanted(label) || value == "") {
                next
            }

            key = normalized SUBSEP label
            if (seen[key]++) {
                next
            }

            emit_section(normalized)
            print color("38;5;245", label ":") " " value
        }
    '
}

main() {
    local info_lines
    local max_info_lines

    if [[ "${YAZI_PREVIEW_NO_IMAGE:-0}" != "1" ]] && is_image_mime; then
        render_image
    elif [[ "${YAZI_PREVIEW_NO_IMAGE:-0}" != "1" ]] && is_video_mime; then
        render_video_frame
    fi

    if (( image_block_height > 0 )); then
        max_info_lines=$(( preview_height - image_block_height ))
        if (( max_info_lines < 4 )); then
            max_info_lines=4
        fi
    else
        max_info_lines="$preview_height"
    fi

    info_lines="$(render_mediainfo || true)"

    if [[ -z "$info_lines" ]]; then
        render_fallback
        exit 0
    fi

    printf '%s\n' "$info_lines" | head -n "$max_info_lines"
}

main "$@"
