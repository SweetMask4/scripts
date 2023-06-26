#!/usr/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

dependencies=("man")

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh "${dependencies[@]}" || exit 1

function main() {
  # An array of options to choose.
  local _options=(" Search manpages" " Random manpage" "󰗼 Quit")
  # Piping the above array into dmenu.
  # We use "printf '%s\n'" to format the array one item to a line.
  choice=$(printf '%s\n' "${_options[@]}" | ${LAUNCHER} ' Manpages:')

  # What to do when/if we choose one of the options.
  case "$choice" in
    ' Search manpages')
      # shellcheck disable=SC2086
      man -k . | awk '{$3="-"; print $0}' |
        ${LAUNCHER} 'Search for:' |
        awk '{print $2, $1}' | tr -d '()' | xargs $TERMINAL_EMULATOR man
      ;;
    ' Random manpage')
      # shellcheck disable=SC2086
      man -k . | cut -d' ' -f1 | shuf -n 1 |
        ${LAUNCHER} 'Random manpage:' | xargs $TERMINAL_EMULATOR man
      ;;
    '󰗼 Quit')
      success "Program terminated."
      ;;
    *)
      exit 0
      ;;
  esac

}
main
