#!/usr/bin/env bash

set -u

case "${1:-get}" in
    up)
        ddcutil setvcp 10 + 5 >/dev/null 2>&1 || exit 1
        ;;
    down)
        ddcutil setvcp 10 - 5 >/dev/null 2>&1 || exit 1
        ;;
    get)
        ;;
    *)
        exit 2
        ;;
esac

brightness="$({ LC_ALL=C ddcutil getvcp 10 --brief 2>/dev/null || true; } |
    awk '$1 == "VCP" && $2 == "10" { print $4, $5; exit }')"

read -r current maximum <<< "${brightness}"

if [[ ! "${current:-}" =~ ^[0-9]+$ ]] ||
   [[ ! "${maximum:-}" =~ ^[0-9]+$ ]] ||
   ((maximum == 0)); then
    exit 1
fi

percentage=$(((current * 100 + maximum / 2) / maximum))
printf '{"percentage":%d}\n' "${percentage}"
