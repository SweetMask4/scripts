#!/bin/bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

dependencies=("maim" "xdotool" "xrandr")

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh "${dependencies[@]}" || exit 1

# Plays a camera shutter sound if the sound file exists
sound() {
    sound_file="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga"
    if [ -f "$sound_file" ]; then
        paplay "$sound_file"
    fi
}

# Get current timestamp
get_timestamp() {
    date '+%Y%m%d-%H%M%S'
}

# local version of cp2cb is needed to account for dm-maim's specific usage
cp2cb-maim() {
    case "$XDG_SESSION_TYPE" in
        'x11') xclip -selection clipboard -t image/png ;;
        'wayland') wl-copy -t image/png ;;
        *) err "Unknown display server" ;;
    esac
}

main() {
    local _maim_args=""
    local _file_type=""
    # Makes sure the directory exists.
    # shellcheck disable=SC2154
    mkdir -p "${maim_dir}"

    declare -a modes=(
        " Fullscreen"
        "󰹑 Active window"
        "󰒅 Selected region"
    )
    # Get monitors and their settings for maim

    # Grepping with awk here, /+/ means return only lines with +, ie grep
    # On that note, this could probably be written more efficiently in one awk
    # command as opposed to two however I am not an awk guru soo...
    _displays=$(xrandr --listactivemonitors | awk '/+/ {print $4, $3}' | awk -F'[x/+* ]' '{print $1,$2"x"$4"+"$6"+"$7}')

    # Add monitor data

    # If I'm understanding correctly this should work however bear in mind I run
    # a single monitor setup so some testing is needed before this is merged
    IFS=$'\n'
    declare -A _display_mode
    for i in ${_displays}; do
        # These lines are commented because I believe it can be done faster with
        # some different syntax. Luke smith has done a video about this efficiency
        # and it has been used in earlier scripts

        # name=$(echo "${i}" | awk '{print $1}')
        # rest="$(echo "${i}" | awk '{print $2}')"

        # Think of "i%% *" as awk '{print $1}' in this case, it isn't a 1 to 1 but
        # for this example it does the same thing, same applies for "i##* " but for
        # awk '{print $2}'. Using two of the % or # symbols means "greedy", it will
        # only leave 1 word remaining (so if we had var="apple orange pear" and did
        # echo "${var%% *}, it would return apple where as "${var% *}" returns all
        # but the very last word.
        modes[${#modes[@]}]="${i%% *}"
        _display_mode[${i%% *}]="${i##* }"
    done
    unset IFS

    target=$(printf '%s\n' "${modes[@]}" | ${DMENU} '󰹑 Take screenshot of:' "$@") || exit 1
    case "$target" in
        ' Fullscreen')
            _file_type="full"
            ;;
        '󰹑 Active window')
            active_window=$(xdotool getactivewindow)
            _maim_args="-i ${active_window}"
            _file_type="window"
            ;;
        '󰒅 Selected region')
            _maim_args="-s"
            _file_type="region"
            ;;
        *)
            _maim_args="-g ${_display_mode[${target}]}"
            _file_type="${target}"
            ;;
    esac

    delay=$(printf '%s\n' "$(seq 0 5)" | ${DMENU} ' Delay (in seconds):' "$@") || exit 1
    if [ ! "${delay}" -eq "0" ]; then
        _maim_args="${_maim_args} --delay=${delay}"
    else
        _maim_args="${_maim_args} --delay=0.5"
    fi

    _maim_args="${_maim_args} -q"
    local destination=(" File" "󱉦 Clipboard" " Both" " Extract qr")
    dest=$(printf '%s\n' "${destination[@]}" | ${DMENU} ' Destination:' "$@") || exit 1
    case "$dest" in
        ' File')
            # shellcheck disable=SC2086,SC2154
            maim ${_maim_args} "${maim_dir}/${maim_file_prefix}-${_file_type}-$(get_timestamp).png"
            notify-send "Saved Screenshot" "${maim_dir}/${maim_file_prefix}-${_file_type}-$(get_timestamp).png"
            sound
            ;;
        '󱉦 Clipboard')
            # shellcheck disable=SC2086
            maim ${_maim_args} | cp2cb-maim
            notify-send "Saved Screenshot" "Clipboard"
            sound
            ;;
        ' Both')
            # shellcheck disable=SC2086
            maim ${_maim_args} | tee "${maim_dir}/${maim_file_prefix}-${_file_type}-$(get_timestamp).png" | cp2cb-maim
            notify-send "Saved Screenshot" "${maim_dir}/${maim_file_prefix}-${_file_type}-$(get_timestamp).png And Clipboard"
            sound
            ;;
        ' Extract qr')
            temp=$(mktemp -p "$XDG_RUNTIME_DIR" --suffix=.png)
            trap 'rm -f $temp' HUP INT QUIT TERM PWR Exit

            maim -s "$temp" || exit 1
            qr_output="$(zbarimg -q "$temp" )"
            qr_output="${qr_output#QR-Code:}"

            if [[ -n "$qr_output" ]]; then
                echo "$qr_output" | xclip -selection clipboard
                notify-send "QR Code Detected" "$qr_output"
            else
                notify-send "No QR Code Found" "No QR code was detected in the screenshot."
            fi
            sound
            ;;
        *)
            exit 1
            ;;
    esac
}

main "$@"
