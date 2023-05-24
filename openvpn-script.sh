#!/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

dependencies=("openvpn" "yad")

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/_menu-helper.sh "${dependencies[@]}" || exit 1

# Get directory where .ovpn files are located
VPN_DIR="$HOME/Documents/openvpn/"
VPN_LOGIN="$HOME/.config/openvpn/login.conf"
VPN_CONFIG="$HOME/.config/openvpn"

# Verify directory exists
[ -d "$VPN_DIR" ] || {
    echo "Directory '$VPN_DIR' does not exist"
    exit 1
}
[ -d "$VPN_CONFIG" ] || mkdir -p "$VPN_CONFIG"

# Get list of .ovpn files in directory
VPN_FILES=("$VPN_DIR"/*.ovpn)

# Verify there is at least one .ovpn file in the directory
((${#VPN_FILES[@]})) || {
    echo "No .ovpn files found in directory '$VPN_DIR'"
    exit 1
}

# Function to connect to VPN
connect_vpn() {
    # Obtener el archivo .ovpn seleccionado por el usuario
    SELECTED_VPN=$(printf '%s\n' "${VPN_FILES[@]##*/}" | ${LAUNCHER} ' Select .ovpn file')

    # Verify selected file exists
    [ -f "$VPN_DIR/$SELECTED_VPN" ] || {
        echo "File '$SELECTED_VPN' does not exist in directory '$VPN_DIR'"
        exit 1
    }

    if [ -f "$VPN_LOGIN" ]; then
        # Connect to the selected VPN using the stored login data
        pkexec openvpn --config "$VPN_DIR/$SELECTED_VPN" --auth-user-pass "$VPN_LOGIN"
    else
        # Get the username and password for the VPN connection using Yad
        USERNAME=$(yad --title="VPN Username" --entry --entry-label="Username: " --width=300 --center)
        PASSWORD=$(yad --title="VPN Password" --entry --entry-label="Password: " --hide-text --width=300 --center)

        # Store the username and password in the login data file
        echo -e "$USERNAME\n$PASSWORD" >"$VPN_LOGIN"

        # Connect to the selected VPN using the stored login data
        pkexec openvpn --config "$VPN_DIR$/SELECTED_VPN" --auth-user-pass "$VPN_LOGIN"
    fi
    # Verify if connection was successful
    pgrep -x "openvpn" >/dev/null && notify-send "VPN connection successful"

}

# Function to disconnect from VPN
disconnect_vpn() {
    # Verificar si se está conectado al VPN
    pgrep -x "openvpn" >/dev/null || {
        echo "You are not connected to VPN"
        exit 1
    }
    # Disconnect from VPN
    pkexec killall openvpn
    # Notify that VPN has been disconnected
    notify-send "VPN disconnected successfully"
}

# Función principal
main() {
    declare -a options=(" Connect to VPN" " Disconnect from VPN")
    CHOICE=$(printf '%s\n' "${options[@]}" | ${LAUNCHER} ' Option:' "${@}")

    case "$CHOICE" in
        " Connect to VPN") connect_vpn ;;
        " Disconnect from VPN") disconnect_vpn ;;
        *) exit 0 ;;
    esac
}

# Execute main function if script is executed directly
main "$@"
