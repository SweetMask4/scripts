#!/usr/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

# script will not hit this if there is no config-file to load
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh || exit 1


main() {
    # Running ps to get running processes and display in dmenu.
    # In this script we use a variable called $DDMENU, in your scripts, you
    # should just write dmenu or rofi or whatever launcher you use.
    selected="$(ps --user "$USER" -F \
        | ${DMENU} "Search for process to kill:" \
        | awk '{print $2" "$11}')"

    # Nested 'if' statements.  The outer 'if' statement is what to do
    # when we select one of the 'selected' options listed in dmenu.
    if [[ -n $selected ]]; then
        # Piping No/Yes into dmenu as a safety measure, in case you
        answer="$(echo -e "No\nYes" | ${DMENU} "Kill $selected?")"

        if [[ $answer == "Yes" ]]; then
            # This echo command prints everything before the first space.
            # Luke Smith has a video on why this is most efficient in this case
            # An alternative way to do it would be with awk or cut, both are less
            # efficient however.
            kill -9 "${selected%% *}"
            echo "Process $selected has been killed." && exit 0
        else
            # We want this script to exit with a 1 and not 0 because 1 means
            # an error, so this can be handled by other scripts better
            echo "User choose not to kill a process." && exit 1
        fi
    fi
}


main
