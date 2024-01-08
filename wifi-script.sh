#!/usr/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

dependencies=("yad")
# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh "${dependencies[@]}" || exit 1

if command -v connmanctl &>/dev/null;then
    backend="connman"
    network_cmd="connmanctl"
elif command -v networkmanager &> /dev/null; then
    backend="networkmanager"
    network_cmd="nmcli"
else
    err "Neither Connman nor NetworkManager are installed on the system."
fi

get_wifi_list() {
    state=$1
    if [[ "$backend" == "connman" ]]; then
        bssid=$("$network_cmd" services | awk '{print $NF}'| ${DMENU} "Select Wifi 󰤥 :")
        network_cmd="connmanctl"
    elif [[ "$backend" == "networkmanager" ]]; then
        bssid=$("$network_cmd" list | sed -n '1!p' | cut -b 9- | ${DMENU} "Select Wifi 󰤥 :" | cut -d' ' -f1)
        network_cmd="nmcli device wifi"
    fi

    if [[ "$backend" == "connman" && "$state" == "connect" ]]; then
        network_cmd+=" connect"
        elif [[ "$backend" == "connman" && "$state" == "disconnect" ]];then
        network_cmd+=" disconnect"
    else
        bssid=$(nmcli device wifi list | sed -n '1!p' | cut -b 9- | ${DMENU} "Select Wifi 󰤥 :" | cut -d' ' -f3)
        network_cmd="nmcli connection down"
    fi
}

connect_wifi() {
    get_wifi_list "connect"
    pass=$(yad --title="Connect to the Internet" --entry --entry-label="Password: " --hide-text)

    if [[ -n "$pass" && "$backend" == networkmanager ]];then
        $network_cmd "$bssid" password "$pass"
    else
        $network_cmd "$bssid"
    fi

    sleep 10
    if ping -q -c 2 -W 2 archlinux.org >/dev/null; then
        notify-send "Network Status" "Internet connection is available"
    else
        notify-send "Network Status" "No internet connection"
    fi
}

disconnect_wifi() {
    get_wifi_list "disconnect"
    $network_cmd "$bssid"
    sleep 2
    notify-send "has been disconnected $bssid"
}

main() {
    options=("󰤥 Connect wifi" "󰤮 Disconnect wifi")
    choice=$(printf '%s\n' "${options[@]}" | ${DMENU} '󰤥 Network option:')
    case $choice in
        "󰤥 Connect wifi") connect_wifi ;;
        "󰤮 Disconnect wifi") disconnect_wifi ;;
    esac
}

main
