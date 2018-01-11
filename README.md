# awesome-config
This is the [awesome WM](http://awesome.naquadah.org/) config I have fined-tuned for my daily use.
I am currently running it on awesome v4.2 on Debian sid (work profile) and Mint 17 (home profile).

## Design highlights ##

Uses tiling for long-lived windows (for writing, programing or reading
etc), while floating for temporary windows (dialogs, file manager, IM,
settings etc).  Based on that idea:

  - All windows are initially floating, and
  - Floating windows are always "on top", thus in front of tiling windows

Use tags (a.k.a., workspaces, virtual desktops) to group windows
related to the same task.  A tag's name should reflect the task, thus
should be able to easily changed.

  - Make a key binding for changing the tag name in-place.

The interface should be clean while informative and functional.

  - Removed the traditional top titlebar that has window title text
    and buttons etc.  Window title is already displayed in the task
    bar.
  - The color scheme is designed to best highlight the focus window,
    and build a strong visual connection between it and its task bar
    entry.
  - Use a no-content title bar at the bottom as an extension to the
    border, which enhances the highlighting for the focus, and also
    serves as a more natural moving and resizing handle than the
    original top title bar.

Most essential functionality should be easily accessible from both
keyboard and mouse.

  - Provide both menu entries and shortcuts for most actions, e.g.,
    launching the terminal and browser, changing the layout etc.
  - Allow moving and resizing windows with keyboard only.
  - Re-assign window-switching bindings from `Mod-J/K` to `Mod-A/S`
    to allow single-handed operation.

Responses to user inputs should be deterministic.

  - Avoid toggle-type key-bindings.  For example, assign separate keys
    for floating and or tiling a window, instead of assign one key to
    toggle floating state.

Additional shortcuts and changes to default key bindings.

## Other features ##
 - Doesn't use any third-party awesome extensions.
 - Support multiple profiles that let me have small tweaks (theming, autostarts
   etc) on my differnt machines. Use `switch_profile.sh {work|work_thinkpad|home}` to swich
   between profiles.
 - Randomized wallpaper (link `~/.config/awesome/runtime/wallpapers` to where the wallpapers are).

## Dependencies ##
It uses the following applications / packages:
 - __xfce4-terminal__ as the terminal emulator (`Mod+Enter`)
 - __xfce4-panel__ to display the notification icons, because GTK+2 applications may
   [crash with awesome's systray](https://github.com/awesomeWM/awesome/issues/891)
 - __xfce4-power-manager__ for the battery icon on laptops
 - __xscreensaver__ for screen lock (`Mod+F12`)
 - __xbacklight__ for adjusting screen backlight
 - __python-gtk2__ for the quick search dialog (`Mod+F10`)
 - [__pulseaudio-ctl__](https://github.com/graysky2/pulseaudio-ctl) for volume control (`Mod+{KP_Add|KP_Subtract|KP_Multiply}`)
 - __ibus__ for Chinese input (`Mod+Space`)
 - __thunar__ as the file manager (`Mod+]`)
 - __Google Chrome__ as the web browser (`Mod+\`)
 - __redshift__ for adjusting color temperature
 - __feh__ for setting the wallpaper

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

Set up `awesome.sh` as the awesome startup script:
```
$ sudo cp ~/.config/awesome/awesome.sh /usr/local/bin
$ sudo chmod a+rx /usr/local/bin/awesome.sh
```

To add desktop menu entry in display manager, create
`/usr/share/xsessions/awesome-local.desktop`:
```
[Desktop Entry]
Encoding=UTF-8
Name=awesome-local
Comment=Highly configurable framework window manager
TryExec=/usr/local/bin/awesome.sh
Exec=/usr/local/bin/awesome.sh
Type=Application
```

To set up environment variables, put it in `~/.xsessionrc`, e.g.:
```
export PATH=$HOME/bin:$HOME/.emacs.d/bin:$PATH
CLUTTER_IM_MODULE=ibus
QT4_IM_MODULE=ibus
GTK_IM_MODULE=ibus
```

(Optional) link the wallpaper directory as the source of randomized wallpapers. If you skip this step,
the default wallpaper will be used.
```
$ ln -s ~/Pictures/wallpapers ~/.config/awesome/runtime/wallpapers
```

## Screenshots (outdated) ##

Vertically split, with the layout menu shown at the top-right by
clicking the layout icon.  On the top-right there is also the clock
widget and the current input method (英 for English, 拼 for Chinese
Pinyin).  There are also the WiFi status and power status when the
`work_thinkpad` is chosen.

<img src="https://github.com/zhangkun83/awesome-config/blob/master/screenshots/3-split.jpg" width="640">

Tiling windows in the background, with a window (the Quick Search box
summoned by `Mod+F10`) floating on top.  A 3-month calendar is shown
when the clock is clicked.

<img src="https://github.com/zhangkun83/awesome-config/blob/master/screenshots/3-floating-on-top.jpg" width="640">

The floating layout. The blue bottom bar can be used to move (left button) and resize (right button) the window.

<img src="https://github.com/zhangkun83/awesome-config/blob/master/screenshots/3-floating.jpg" width="640">
