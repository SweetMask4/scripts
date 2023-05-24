#!/usr/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/_menu-helper.sh || exit 1

_out="echo"
if [[ ${TERM} == 'dumb' ]]; then
    _out="notify-send"
fi

output() {
    ${_out} "power-menu" "$@"
}

desktop() {
    case "$XDG_SESSION_TYPE" in
        'x11') grep "Name=" /usr/share/xsessions/*.desktop | cut -d'=' -f2 ;;
        'wayland') grep "Name=" /usr/share/wayland-sessions/*.desktop | cut -d'=' -f2 || grep "Name=" /usr/share/xsessions/*.desktop | grep -i "wayland" | cut -d'=' -f2 | cut -d' ' -f1 ;;
        *) err "Unknown display server" ;;
    esac
}

options(){
    if command -v systemd &>/dev/null;then
        systemctl "$1"
    else
        pkexec "$1"
    fi
}

main() {
    # An array of options to choose.
    declare -a options=(
        " Lock screen"
        " Logout"
        " Reboot"
        " Shutdown"
        " Suspend"
        "Quit"
    )
    declare -a MANAGERS
    while IFS= read -r manager; do
        MANAGERS+=("${manager,,}")
    done < <(desktop)

    choice=$(printf '%s\n' "${options[@]}" | ${LAUNCHER} ' Shutdown menu:' "${@}")
    # What to do when/if we choose one of the options.
    case $choice in
        ' Logout')
            if [[ "$(echo -e "No\nYes" | ${LAUNCHER} "${choice}?" "${@}")" == "Yes" ]]; then
                warning
                for manager in "${MANAGERS[@]}"; do
                    killall "${manager}" || output "Process ${manager} was not running."
                done
            else
                output "User chose not to logout." && exit 1
            fi
            ;;
        ' Lock screen')
            ${logout_locker}
            ;;
        ' Reboot')
            if [[ "$(echo -e "No\nYes" | ${LAUNCHER} "${choice}?" "${@}")" == "Yes" ]]; then
                options "reboot"
            else
                output "User chose not to reboot." && exit 0
            fi
            ;;
        ' Shutdown')
            if [[ "$(echo -e "No\nYes" | ${LAUNCHER} "${choice}?" "${@}")" == "Yes" ]]; then
                options "poweroff"
            else
                output "User chose not to shutdown." && exit 0
            fi
            ;;
        ' Suspend')
            if [[ "$(echo -e "No\nYes" | ${LAUNCHER} "${choice}?" "${@}")" == "Yes" ]]; then
                options "suspend"
            else
                output "User chose not to suspend." && exit 0
            fi
            ;;
        'Quit')
            output "Program terminated." && exit 0
            ;;
            # It is a common practice to use the wildcard asterisk symbol (*) as a final
            # pattern to define the default case. This pattern will always match.
        *)
            exit 0
            ;;
    esac

}
main "$@"
