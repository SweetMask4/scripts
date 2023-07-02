#!/usr/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

# script will not hit this if there is no config-file to load
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh || exit 1

main() {
    # Running ps to get running processes and display in dmenu.
    # In this script we use a variable called $LAUNCHER, in your scripts, you
    # should just write dmenu or rofi or whatever launcher you use.
    selected=$(ps --user "$USER" -F | awk '{print $2" "$11$12}' | ${LAUNCHER} " Search process to kill:")

    [[ -n "$selected" ]] && answer=$(echo -e "No\nYes" | ${LAUNCHER} "Kill $selected?")

    if [[ "$answer" == "Yes" ]]; then
        kill -9 "${selected%% *}" && echo "Process $selected has been killed." && exit 0
    else
        success "Program terminated."
    fi
}

main
