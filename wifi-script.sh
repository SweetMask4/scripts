#!/usr/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

dependencies=("networkmanager" "yad" "nmcli")

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh "${dependencies[@]}" || exit 1

connect_wifi() {
    bssid=$(nmcli device wifi list | sed -n '1!p' | cut -b 9- | ${LAUNCHER} "Select Wifi 󰤥 :" | cut -d' ' -f1)
    pass=$(yad --title="Connect to the Internet" --entry --entry-label="Password: " --hide-text)
    if [ -n "$pass" ];then
        nmcli device wifi connect "$bssid" password "$pass"
    else
        nmcli device wifi connect "$bssid"
    fi
    sleep 10
    if ping -q -c 2 -W 2 archlinux.org >/dev/null;then
        notify-send "Network Manager" "has internet connection"
    else
        notify-send "Network Manager" "no internet connection"
    fi
}

disconnect_wifi() {
    bssid=$(nmcli device wifi list | sed -n '1!p' | cut -b 9- | ${LAUNCHER} "Select Wifi 󰤥 :" | cut -d' ' -f3)
    nmcli connection down "$bssid"
    sleep 2
    notify-send "has been disconnected $bssid"
}

main() {
    options=("󰤥 Connect wifi" "󰤮 Disconnect wifi")
    choice=$(printf '%s\n' "${options[@]}" | ${LAUNCHER} '󰤥 Network option:' "${@}")
    case $choice in
        "󰤥 Connect wifi") connect_wifi ;;
        "󰤮 Disconnect wifi") disconnect_wifi ;;
    esac
}

main "$@"
