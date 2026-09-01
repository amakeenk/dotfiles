#!/usr/bin/env bash

set -euo pipefail

file_path="${1:?missing file path}"
preview_height="${2:-24}"
preview_colors=1

if [[ -n "${NO_COLOR:-}" || "${TERM:-}" == "dumb" ]]; then
    preview_colors=0
fi

detect_mime() {
    file -Lb --mime-type -- "$file_path" 2>/dev/null || true
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

    info_lines="$(render_mediainfo || true)"

    if [[ -z "$info_lines" ]]; then
        render_fallback
        exit 0
    fi

    printf '%s\n' "$info_lines" | head -n "$preview_height"
}

main "$@"
