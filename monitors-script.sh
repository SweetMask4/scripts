#!/usr/bin/env bash
#
# dmenu menu to:
# - enable second display as mirrored
# - enable second display as second monitor
# - disable default display
# - disable second display
#

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

dependencies=("xrandr" "pulseaudio" "xwallpaper")

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh "${dependencies[@]}" || exit 1

_reload_wallpaper() {
    xargs xwallpaper --stretch <~/.config/wall
}

# Enable second display as second monitor
_second_as_monitor() {
    declare -a options=(" left" " right" " above" " below")

    SIDE=$(printf '%s\n' "${options[@]}" | ${DMENU} "󰍺 Second as monitor")
    case $SIDE in
        " left") xrandr --output "$SECOND" --auto --left-of "$DEFAULT" && _reload_wallpaper ;;
        " right") xrandr --output "$SECOND" --auto --right-of "$DEFAULT" && _reload_wallpaper ;;
        " above") xrandr --output "$SECOND" --auto --above "$DEFAULT" && _reload_wallpaper ;;
        " below") xrandr --output "$SECOND" --auto --below "$DEFAULT" && _reload_wallpaper ;;
        *) exit 0 ;;
    esac
}

# Switch audio output
switch_audio_output() {
    DEVICES=$(pacmd list-cards | awk -F '[<>]' '/name:/ {print $2}')
    PROFILES=$(pacmd list-cards | grep 'output:' | awk '{print substr($1, 1, length($1)-1)}' | grep -v 'activ')

    if [[ "$(echo -e "No\nYes" | ${DMENU} " change audio profile")" == "Yes" ]]; then
        Selected_Profile=$(printf '%s\n' "${PROFILES[@]}" | ${DMENU} ' Available profiles:')
        # Change the default audio output device to the selected device
        pacmd set-card-profile "$DEVICES" "$Selected_Profile"
    fi
}

# Main function
main() {
    # Get the current connected monitors
    connected_monitors=$(xrandr | awk '/ connected/{printf "%s ",$1}')
    number_of_monitors=$(echo "$connected_monitors" | wc -w)

    if [ "$number_of_monitors" -eq 2 ]; then
        declare -a options=("󰍺 Second as monitor" "󱒃 Second as mirror" "󰶐 Second disabled" "󰶐 Default disabled")
        DEFAULT=$(echo "$connected_monitors" | awk '{print $1}')
        SECOND=$(echo "$connected_monitors" | awk '{print $2}')

        choice=$(printf '%s\n' "${options[@]}" | ${DMENU} '󰍹 Display option: ')
        case $choice in
            '󰍺 Second as monitor') _second_as_monitor ;;
            '󱒃 Second as mirror') xrandr --output "$SECOND" --auto --same-as "$DEFAULT" && _reload_wallpaper ;;
            '󰶐 Second disabled') xrandr --output "$SECOND" --off --output "$DEFAULT" --auto && dunst & ;;
            '󰶐 Default disabled') switch_audio_output && xrandr --output "$DEFAULT" --off --output "$SECOND" --auto && _reload_wallpaper && killall dunst | start ;;
            *) exit 0 ;;
        esac
    else
        success "Error: Please connect two monitors."
    fi
}
main
