#!/usr/bin/env bash

# NetworkManager identifies conventional VPN profiles as "vpn" and native
# WireGuard profiles as "wireguard". Output their active connection names.
LC_ALL=C nmcli --terse --escape no --fields NAME,TYPE connection show --active 2>/dev/null |
    awk '/:(vpn|wireguard)$/ {
        sub(/:(vpn|wireguard)$/, "")
        printf "%s%s", separator, $0
        separator = ", "
        found = 1
    }
    END {
        if (found) {
            print ""
        }
    }'
