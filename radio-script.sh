#!/usr/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

dependencies=("mpv")

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh "${dependencies[@]}" || exit 1

menu() {
    printf '%s\n' "Quit"
    # shellcheck disable=SC2154
    printf '%s\n' "${!radio_stations[@]}" | sort
}

# Functions for sending notification messages
start_radio() {
    notify-send "Starting radio" "Playing station: $1. 🎶"
}

end_radio() {
    notify-send "Stopping radio" "You have quit radio-script. 🎶"
}

main() {
    # Choosing a radio station from array sourced in 'config'.
    choice=$(menu | ${DMENU} ' Choose radio station:' "$@") || exit 1

    case $choice in
        Quit)
            end_radio
            pkill -f http
            exit
            ;;
        *)
            pkill -f http || echo "mpv not running."
            start_radio "$choice"
            mpv "${radio_stations["${choice}"]}"
            return
            ;;
    esac

}
main "$@"
