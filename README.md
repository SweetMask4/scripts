# scripts

## introduction

this is a suite of scripts that work with both dmenu and rofi and have the following features:

- `wifi-script.sh` (requiere: `nmcli`, `yad`)
- `maim-script.sh` (requiere: `maim`, `xdotool`)
- `openvpn-script.sh` (requiere: `openvpn`, `yad`)
- `note-manager.sh` (requiere: `ripgrep`)
- `logout-script.sh` (requiere `slock`)
- `monitors-script.sh` (requiere: `xorg`, `xrandr`, `xwallpaper`, `pulseaudio`)
- `maim-script.sh` (requiere: `xwallpaper`)
- `record-script.sh` (requiere: `ffmpeg`, `xrandr`)
- `confedit-script.sh`
- `kill-script.sh`
- `helper-script.sh`
- `radio-script.sh` (requiere: `mpv`)

# Screenshots

![menu-logout](https://github.com/SweetMask4/scripts/blob/main/screenshots/launch-logout-dmenu.png?raw=true)
![menu-note](https://github.com/SweetMask4/scripts/blob/main/screenshots/launch-note-rofi.png?raw=true)

# installation

```shell
git clone https://github.com/SweetMask4/scripts.git ~/
```

add this to your .zshrc or .bashrc file so the script can be called from anywhere on your system

```shell
if [ -d "$HOME/scripts" ] ;
  then PATH="$HOME/scripts:$PATH"
fi
```
is configured in ~/scripts/config/config
here you can configure the editor of your choice

```shell
#TEXT_EDITOR="emacsclient -c -a emacs"
TEXT_EDITOR="${TERMINAL_EMULATOR} nvim"
```

is configured in ~/scripts/config/config
comment on the one you don't use and uncomment on the one you will use example

```shell
# DMENU="dmenu -i -p"
DMENU="rofi -dmenu -i -p"
```
