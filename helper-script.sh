#!/usr/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This is a helper-script it does not do anything on its own."
    exit 1
fi

# List of required dependencies
dependencies=("$@")

# Check if required dependencies are installed
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        echo "$dep is not installed. Please install this dependency before continuing."
        exit 1
    fi
done

desktop() {
    case "$XDG_SESSION_TYPE" in
        'x11') [ -d "/usr/share/xsessions" ] && grep "Name=" /usr/share/xsessions/*.desktop | cut -d'=' -f2
            [ -d "/usr/local/share/xsession" ] && grep "Name=" /usr/local/share/xsession/*.desktop | cut -d'=' -f2 ;;
        'wayland') grep "Name=" /usr/share/wayland-sessions/*.desktop | cut -d'=' -f2 || grep "Name=" /usr/share/xsessions/*.desktop | grep -i "wayland" | cut -d'=' -f2 | cut -d' ' -f1 ;;

        *)
            err "Unknown display server" ;;
    esac
}

# Function to copy to clipboard with different tools depending on the display server
cp2cb() {
    case "$XDG_SESSION_TYPE" in
    'x11') xclip -r -selection clipboard ;;
    'wayland') wl-copy -n ;;
    *) err "Unknown display server" ;;
    esac
}

# Simple warn function
warn() {
    printf 'Warn: %s\n' "$1"
}

# Simple error function
err() {
    printf 'Error: %s\n' "$1"
    exit 1
}

# Simple success function
success() {
    printf 'Success: %s\n' "$1"
    exit 0
}

# load config
# shellcheck disable=SC1090
. ~/scripts/config/config || exit 1
