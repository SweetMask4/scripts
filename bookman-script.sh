#!/usr/bin/env bash

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh || exit 1

# A separator that will appear in between quickmarks, bookmarks and history URLs.
_bookman_separator="----------"
# Defining location of bookmarks file
_bookmark_file="$HOME/.local/share/bookmarks/bookmarks"

show() {
    local list=""

    if [[ -f ${_bookmark_file} ]]; then
        local bmlist=''
        bmlist=$(awk '{print $2" - "$1}' "${_bookmark_file}")
        [[ -n "${bmlist}" ]] && list="$(printf '%s\n' "${list}" "${bmlist}" "${_bookman_separator}")"
    fi

    # Piping the lists into dmenu.
    # We use "printf '%s\n'" to format the array one item to a line.
    # The URLs are listed quickmarks, bookmarks and lastly history
    local choice=
    choice=$(printf '%s\n' "${list}" | sed '/^[[:space:]]*$/d' | ${DMENU} "${DMBROWSER} open:")

    # What to do if the separator is chosen from the list.
    # We simply launch qutebrowser without any URL arguments.
    if [ -n "$choice" ]; then
        [[ "$choice" == "$_bookman_separator" ]] && exit 1
        # What to do when/if we choose a URL to view.
        # url=$(echo "${choice}" | awk '{print $NF}') || exit 1
        nohup "${DMBROWSER}" "${choice##* }" >/dev/null 2>&1 &
    else
        # What to do if we just escape without choosing anything.
        echo "Program terminated." && exit 1
    fi
}

add(){
    url=$(xclip -o)

    if echo "$url" | grep -q "https*://\S\+\.[A-Za-z]\+\S*" ; then
        if grep -q "^$url$" "$_bookmark_file";
        then
            notify-send "already has this bookmarks"
        else
            notify-send "added bookmarks"
            echo "$url" >> "$_bookmark_file"
        fi
    else
        notify-send "That doesn't look like a full URL." && exit 1
    fi
}

choice=$(printf "show\nadd\nexit" | ${DMENU} " bookmarks: " )
case "$choice" in
    "add") add ;;
    "show") show ;;
    *) exit 0 ;;
esac
