# awesome-config

This is the [awesome WM](http://awesome.naquadah.org/) config I have
fined-tuned for my daily use.  I am currently running it on awesome
v4.2 on Debian tesing (buster), using `work` and `work_thinkpad`
profile.

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

  - Only show the traditional top titlebar with window title text on
    floating windows.
  - The color scheme is designed to best highlight the focus window,
    and build a strong visual connection between it and its task bar
    entry.
  - Use a bottom bar at an extension to the border, which enhances the
    highlighting for the focus, and also serves as a more natural
    resizing handle than the top title bar.

Most essential functionality should be easily accessible from both
keyboard and mouse.

  - Provide both menu entries and shortcuts for most actions, e.g.,
    launching the terminal and browser, changing the layout etc.
  - Allow moving and resizing windows with keyboard only.
  - Re-assign window-switching bindings from `Mod-J/K` to `Mod-A/S`
    to allow single-handed operation.

Responses to user inputs should be deterministic.

  - Avoid toggle-style key-bindings.  For example, assign separate keys
    for floating and or tiling a window, instead of assign one key to
    toggle floating state.

Additional shortcuts and changes to default key bindings.

## Other features ##
 - Self-contained: doesn't use any third-party awesome extensions.
 - Support multiple profiles that let me have small tweaks (theming,
   autostarts etc) on my differnt machines. Use `switch_profile.sh
   {work|work_thinkpad}` to swich between profiles.
 - Randomized wallpaper (link `~/.config/awesome/runtime/wallpapers`
   to where the wallpapers are).

## Dependencies ##
It uses the following applications / packages:
 - __compton__ as the compositer
 - __urxvt__ as the terminal emulator (`Mod+Enter`)
 - __xfce4-panel__ to display the notification icons, because GTK+2
   applications may
   [crash with awesome's systray](https://github.com/awesomeWM/awesome/issues/891).
   I also have a window list on it that only shows minimized windows,
   because I made the wibar (on the top) skip them.
 - __xfce4-power-manager__ for the battery icon on laptops.  Also
   provides backlight adjustment.
 - __xsecurelock__ for screen lock (`Mod+F12`)
 - __python-gtk2__ for the quick search dialog (`Mod+F10`)
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

Current color scheme works best with HighContrast GTK theme.  Use it
for the key `gtk-theme-name` in both `~/.gtkrc-2.0` and
`~/.config/gtk-3.0/settings.ini`.

(Optional) link the wallpaper directory as the source of randomized wallpapers. If you skip this step,
the default wallpaper will be used.
```
$ ln -s ~/Pictures/wallpapers ~/.config/awesome/runtime/wallpapers
```
