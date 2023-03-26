#!/bin/env bash

# List of required dependencies
dependencies=("maim" "yad" "sxiv" "xwallpaper" "openvpn" "mpv" "rg" "xwininfo")

# Check if required dependencies are installed
for dep in "${dependencies[@]}"; do
  if ! command -v "$dep" &>/dev/null; then
    echo "$dep is not installed. Please install this dependency before continuing."
    exit 1
  fi
done

# load config
# shellcheck disable=SC1090
. ~/scripts/config/config || exit 1
