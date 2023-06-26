#!/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

dependencies=("openvpn" "yad")

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh "${dependencies[@]}" || exit 1

# Get directory where .ovpn files are located
VPN_DIR="$HOME/Documents/openvpn/"
VPN_LOGIN="$HOME/.config/openvpn/login.conf"
VPN_CONFIG="$HOME/.config/openvpn"

# Verify directory exists
[ -d "$VPN_DIR" ] || {
    mkdir "$VPN_DIR"
    notify-send "add the files in this folder $VPN_DIR"
}

mkdir -p "$VPN_CONFIG"

# Get list of .ovpn files in directory
VPN_FILES=("$VPN_DIR"/*.ovpn)

# Verify there is at least one .ovpn file in the directory
((${#VPN_FILES[@]})) || {
    err "No .ovpn files found in directory $VPN_DIR"
}

verify_connection() {
  if pgrep -x "openvpn" &>/dev/null; then
    connection_status="connected"
  else
    connection_status="disconnected"
  fi

  notify-send "VPN is $connection_status"
}


connect_vpn() {
    SELECTED_VPN=$(printf '%s\n' "${VPN_FILES[@]##*/}" | ${LAUNCHER} ' Select .ovpn file')

    if [ -f "$VPN_LOGIN" ]; then
        pkexec openvpn --config "$VPN_DIR/$SELECTED_VPN" --auth-user-pass "$VPN_LOGIN" 
    else
        USERNAME=$(yad --title="VPN Username" --entry --entry-label="Username: ")
        PASSWORD=$(yad --title="VPN Password" --entry --entry-label="Password: " --hide-text)
        
        echo -e "$USERNAME\n$PASSWORD" >"$VPN_LOGIN"

        pkexec openvpn --config "$VPN_DIR$/SELECTED_VPN" --auth-user-pass "$VPN_LOGIN"
    fi
    verify_connection 
}

disconnect_vpn() {
    verify_connection
    pkexec killall openvpn 
    exit 0
}

main() {
    declare -a options=(" Connect to VPN" " Disconnect from VPN")
    CHOICE=$(printf '%s\n' "${options[@]}" | ${LAUNCHER} ' Option:')
    case "$CHOICE" in
        " Connect to VPN") connect_vpn ;;
        " Disconnect from VPN") disconnect_vpn ;;
        *) exit 0 ;;
    esac
}

# Execute main function if script is executed directly
main
