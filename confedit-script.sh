#!/usr/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh || exit 1

main() {
    # Clean options array making sure that the files exist
    declare -A _clean_list
    # As this is loaded from other file it is technically not defined
    # shellcheck disable=SC2154
    for i in "${!confedit_list[@]}"; do
        [[ -f ${confedit_list["${i}"]} ]] && _clean_list["${i}"]=${confedit_list["${i}"]}
    done

    # Piping the above array (cleaned) into dmenu.
    # We use "printf '%s\n'" to format the array one item to a line.
    choice=$(printf '%s\n' "${!_clean_list[@]}" | sort | ${DMENU} ' Edit config:')

    # What to do when/if we choose a file to edit.
    if [ "$choice" ]; then
        cfg=$(printf '%s\n' "${_clean_list["${choice}"]}")
        # shellcheck disable=SC2154
        $TEXT_EDITOR "$cfg"
        # What to do if we just escape without choosing anything.
    else
        success "Program terminated."
    fi
}

main
