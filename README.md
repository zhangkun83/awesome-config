# awesome-config
This is the [awesome WM](http://awesome.naquadah.org/) config I have fined-tuned for my daily use.
I am currently running it on awesome v3.5.9 on Ubuntu 14.04 (work profile) and Mint 17 (home profile).

## Features ##
 - Uses tiling for long-live windows (for writing, programing or reading etc),
   while floating for temporary windows (file manager, IM, settings etc).
   Following features are to accommodate such idea:
  - Windows are initially floating;
  - Floating windows are always "on top", thus in front of tiling windows;
  - `Mod4+Ctrl+F` to tile all windows of the current tag;
  - `Mod4+P` to make a window float and place it in center nicely.
 - The 10th tag, binded to `Mod4+0`
 - Renaming the tag by `Mod4+Shift+=`. Tag names are saved so they survive reboots.
 - Additional shortcuts and changes to default key bindings. See the [cheatsheet](/cheatsheet.txt).
 - My personalized minimalist awesome menu.
 - Customized light-colored theme, with minimalist window title.
 - Doesn't use any third-party awesome extensions.
 - Support multiple profiles that let me have small tweaks (theming, autostarts
   etc) on my differnt machines. Use `switch_profile.sh {work|home}` to swich
   between profiles.
 - Randomized wallpaper (from `jpg` files under `~/.config/awesome/runtime/wallpapers`).

## Dependencies ##
It uses the following applications / packages:
 - __xfce4-terminal__ as the terminal emulator (`Mod+Enter`)
 - __xscreensaver__ for screen lock (`Mod+F12`)
 - __xbacklight__ for adjusting screen backlight
 - __python-gtk2__ for the quick search dialog (`Mod+F10`)
 - __pulseaudio-ctl__ for volume control (`Mod+{KP_Add|KP_Subtract|KP_Multiply}`)
 - __ibus__ for Chinese input (`Ctrl+Space`)
 - __thunar__ as the file manager (`Mod+]`)
 - __Google Chrome__ as the web browser (`Mod+\`)

## Setting up
Clone the repository to `~/.config/awesome`:
```
$ cd ~/.config
$ git clone https://github.com/zhangkun83/awesome-config.git awesome
```
Choose between the `work` and the `home` profile:
```
$ cd ~/.config/awesome
$ ./switch_profile.sh home
```
(Optional) link the wallpaper directory as the source of randomized wallpapers. If you skip this step,
the default wallpaper will be used.
```
$ ln -s ~/Pictures/wallpapers ~/.config/awesome/runtime/wallpapers
```

## Screenshots ##

Tiling windows in the background, with a window just brought to front by `Mod+P`:

<img src="https://github.com/zhangkun83/awesome-config/blob/master/screenshots/place_center.jpg" width="640">

The floating layout:

<img src="https://github.com/zhangkun83/awesome-config/blob/master/screenshots/floating.jpg" width="640">
