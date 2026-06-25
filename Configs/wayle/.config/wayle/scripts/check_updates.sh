#!/usr/bin/env bash

while ! ping -c 1 8.8.8.8 &>/dev/null; do
    sleep 5
done

source ~/.bashrc

UPDATES_COUNT=0

if clean_old_tasks 2>&1 >/dev/null && \
   sudo apt-get update 2>&1 >/dev/null; then
    UPDATES_COUNT="$(sudo apt-get dist-upgrade --dry-run 2>&1 | grep 'будет обновлено' | cut -d' ' -f1)"
fi

if [[ -z "${UPDATES_COUNT}" ]]; then
    UPDATES_COUNT=0
fi

if [[ "${UPDATES_COUNT}" -ne 0 ]]; then
    printf '{"text":"%s","tooltip":"Доступны обновления пакетов: %s","class":"updates pending","alt":"pending","percentage":100}\n' "${UPDATES_COUNT}" "${UPDATES_COUNT}"
else
    printf '%s\n' '{"text":"0","tooltip":"Доступных обновлений пакетов нет","class":"updates idle","alt":"idle","percentage":0}'
fi
