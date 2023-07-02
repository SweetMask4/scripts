# my scripts

## introduction

This set of scripts is designed to enhance your workflow by using tools such as dmenu, rofi, and fzf. Each script included in this suite has been created with the goal of simplifying common tasks, saving you valuable time in your day-to-day routine. Additionally, these scripts are optimized for efficient and hassle-free performance, allowing you to focus on what really matters: your work.

Try this set of scripts today and discover how they can help you improve your productivity in a minimalist and effective manner.

- `wifi-script.sh` (require: `yad`, `networkmanager` or `connman` )
- `maim-script.sh` (requiere: `maim`, `xdotool`, `xorg` or `wayland` )
- `openvpn-script.sh` (requiere: `openvpn`, `yad`)
- `note-manager.sh` (requiere: `ripgrep`)
- `logout-script.sh` (requiere `slock`)
- `monitors-script.sh` (requiere: `xorg`, `xrandr`, `xwallpaper`, `pulseaudio`)
- `maim-script.sh` (requiere: `maim`,`xdotool`)
- `record-script.sh` (require: `ffmpeg`, `xrandr`)
- `bookman-script.sh` (require: `qutebrowser`)
- `confedit-script.sh`
- `kill-script.sh`
- `helper-script.sh`
- `radio-script.sh` (require: `mpv`)

## other requirements
- Nerd fonts

# Screenshots

![dmenu](https://github.com/SweetMask4/scripts/blob/main/screenshots/dmenu.png?raw=true)
![rofi](https://github.com/SweetMask4/scripts/blob/main/screenshots/rofi.png?raw=true)
![fzf](https://github.com/SweetMask4/scripts/blob/main/screenshots/fzf.png?raw=true)

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
# LAUNCHER="dmenu -i -p"
LAUNCHER="rofi -dmenu -i -p"
```
