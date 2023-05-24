#!/usr/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

dependencies=("ffmpeg")

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/_menu-helper.sh "${dependencies[@]}" || exit 1

# Set the video directory path and create it if it doesn't exist
VIDEO="$HOME/Videos/recording"
[ ! -d "$VIDEO" ] && mkdir "$VIDEO"

# Use xrandr to get the current screen resolutions of connected monitors
resolutions=$(xrandr | awk '/\*/{print $1}' | sed 's/\*//'| awk '{printf "%s ",$1}')

# Set the total width and height to 0 initially
total_width=0
total_height=0

# Iterate through each resolution and sum the widths and keep the height constant
for res in $resolutions; do
    # Extract the width and height using awk with the -Fx option
    width=$(echo "$res" | awk -Fx '{print $1}')
    height=$(echo "$res" | awk -Fx '{print $2}')

    # Sum the widths and keep the height constant
    total_width=$((total_width+width))
    total_height=$height
done

# Get the current screen resolution
fullresolution="$total_width"x"$total_height"

# Set the recording framerate
framerate="30"

# Get current timestamp
get_timestamp() {
    date '+%Y%m%d-%H%M%S'
}

killrecording() {
    if [ -f /tmp/recordingpid ]; then
        recpid="$(</tmp/recordingpid)"
        if kill -0 "$recpid" 2> /dev/null; then
            kill -TERM "$recpid"
            sleep 2
        fi
        if kill -0 "$recpid" 2>/dev/null; then
            kill -KILL "$recpid"
        fi
        rm -f /tmp/recordingpid
    fi
    notify-send "Recording has been stopped"
}

screencast() {
    ffmpeg -nostdin -threads 0 -y \
        -f x11grab \
        -r "$framerate" \
        -video_size "$fullresolution" \
        -i "$DISPLAY" \
        -f pulse -i default \
        -c:v h264 -crf 25 -b:v 0 -preset ultrafast -c:a aac \
        "$VIDEO/screencast-$(get_timestamp).mp4" &
    echo $! >/tmp/recordingpid
    notify-send "Screencast recording has started"
}

video() {
    ffmpeg -nostdin -threads 0 -y \
        -f x11grab \
        -video_size "$fullresolution" \
        -i "$DISPLAY" \
        -r "$framerate" \
        -c:v h264  -crf 25 -b:v 0 -preset ultrafast -c:a aac \
        "$VIDEO/video-$(get_timestamp).mp4" &
    echo $! >/tmp/recordingpid
    notify-send "Video recording has started"
}

webcam() {
    ffmpeg \
        -f v4l2 \
        -i /dev/video0 \
        -video_size 640x480 \
        "$VIDEO/webcam-$(get_timestamp).mkv" &
    echo $! >/tmp/recordingpid
    notify-send "Webcam recording has started"
}

audio() {
    ffmpeg \
        -f alsa -i default \
        -f flac \
        "$VIDEO/audio-$(get_timestamp).flac" &
    echo $! >/tmp/recordingpid
    notify-send "Audio recording has started"
}

asktoend() {
    response=$(echo -e "No\nYes" | ${LAUNCHER} 'Recording still active. End recording?')
    [ "$response" = "Yes" ] && killrecording
}

videoselected() {

    readarray -t coords < <(slop -f "%x %y %w %h")
    read -r X Y W H <<<"${coords[0]}"

    ffmpeg \
        -f x11grab \
        -framerate 60 \
        -video_size "$W"x"$H" \
        -i :0.0+"$X,$Y" \
        -c:v libx264 -qp 0 -r $framerate \
        "$VIDEO/box-$(get_timestamp).mkv" &
    echo $! >/tmp/recordingpid
    notify-send "videoselected recording has started"
}

main() {
    choice=$(printf " screencast\n audio\n video\n󰊓 videoselected\n󰖠 webcam\n󰿅 killrecording" | ${LAUNCHER} '󰹑 options for recording')
    case "$choice" in
        ' screencast') screencast ;;
        ' audio') audio ;;
        ' video') video ;;
        '󰊓 videoselected') videoselected ;;
        '󰖠 webcam') webcam ;;
        '󰿅 killrecording') killrecording ;;
        *) ([ -f /tmp/recordingpid ] && asktoend && exit) || maim ;;
    esac
}
main "$@"
