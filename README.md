# scripts

## introduction
this is a suite of scripts that work with both dmenu and rofi and have the following features:

- launch-wifi this script facilitates wifi management 
- launch-maim launch maim this script facilitates screen capturing using maim
- launch-openvpn this script makes it easy to connect to vpn 
- launch-note it facilitates the creation of both basic markdown and advanced markdown notes with latex and the opening of saved books and articles.
- launch-logout facilitates restarting, shutting down and shutting down the WM or DE
- launch-monitors facilitates monitor management by setting up external monitors and allows changing the audio profile.
- launch-setbg makes it easy to change the wallpaper using sxiv giving a similar look to nitrogen.
- launch-confedit facilitates the opening of configuration files
- launch-kill facilitates the closing of malfunctioning programmes 
- launch-man makes it easy to look up a command in man
- launch-radio makes it easier for you to listen to the radio 

# Screenshots
![launch-logout](https://github.com/SweetMask4/scripts/blob/main/screenshots/launch-logout-dmenu.png?raw=true)
![launch-note](https://github.com/SweetMask4/scripts/blob/main/screenshots/launch-note-rofi.png?raw=true)

# installation

``` shell
git clone https://github.com/SweetMask4/scripts.git 
```

add this to your .zshrc or .bashrc file so the script can be called from anywhere on your system
``` shell
if [ -d "$HOME/scripts" ] ;
  then PATH="$HOME/scripts:$PATH"
fi
```
is configured in ~/scripts/config/config
