#!/usr/bin/env bash
# shellcheck disable=SC2154

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

dependencies=("sxiv" "xwallpaper")


# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh "${dependencies[@]}" || exit 1

setbg() {
  if [[ -n "$1" ]]; then
    case "$XDG_SESSION_TYPE" in
      'x11') xwallpaper --stretch "$1" ;;
      'wayland') swaybg -m "stretch" -i "$1" ;;
      *) err "Unknown display server" ;;
    esac
  else
    echo "Wallpaper file path is empty or does not exist"
  fi
}

main() {
  case "$(printf "Set\nRandom\nExit" | ${LAUNCHER} "What would you like to do?")" in
    Set)
      if ((use_imv)); then
        imv "${setbg_dir}" | while read -r LINE; do
          pkill "swaybg" || true
          pkill "xwallpaper" || true
          setbg "$LINE" &
          notify-send "Wallpaper has been updated" "$LINE is the current wallpaper, edit your window manager config if you would like this to persist on reboot"
        done
      else
        wallpaper="$(sxiv -t -o "${setbg_dir}")"
        echo "$wallpaper" >"$HOME/.config/wall"
        setbg "$wallpaper"
      fi
      ;;
    Random)
      valid_paper="No"
      until [[ "$valid_paper" == "Yes" ]]; do
        pkill "swaybg" || true
        pkill "xwallpaper" || true
        wallpaper="$(find "${setbg_dir}" -type f | shuf -n 1)"
        setbg "$wallpaper" &
        echo "$wallpaper" >"$HOME/.config/wall"
        valid_paper="$(printf "Yes\nNo" | ${LAUNCHER} "Do you like the new wallpaper?")"
      done
      ;;
    Exit) echo "Program terminated" && exit 1 ;;
    *) err "Invalid choice" ;;
  esac
}

main "$@"
