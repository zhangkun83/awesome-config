# awesome-config
This is the [awesome WM](http://awesome.naquadah.org/) config I have fined-tuned for my daily use.
I am currently running it on awesome v3.5.9 on Ubuntu 14.04 (work profile) and Mint 17 (home profile).

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
  - Re-assign window-switching bindings from `Mod4-J/K` to `Mod4-A/S`
    to allow single-handed operation.

Responses to user inputs should be deterministic.

  - Avoid toggle-type key-bindings.  For example, assign separate keys
    for floating and or tiling a window, instead of assign one key to
    toggle floating state.

Additional shortcuts and changes to default key bindings can be found
in the [cheatsheet](/cheatsheet.txt).

## Other features ##
 - Doesn't use any third-party awesome extensions.
 - Support multiple profiles that let me have small tweaks (theming, autostarts
   etc) on my differnt machines. Use `switch_profile.sh {work|work_thinkpad|home}` to swich
   between profiles.
 - Randomized wallpaper (link `~/.config/awesome/runtime/wallpapers` to where the wallpapers are).

## Dependencies ##
It uses the following applications / packages:
 - __xfce4-terminal__ as the terminal emulator (`Mod+Enter`)
 - __xscreensaver__ for screen lock (`Mod+F12`)
 - __xbacklight__ for adjusting screen backlight
 - __python-gtk2__ for the quick search dialog (`Mod+F10`)
 - [__pulseaudio-ctl__](https://github.com/graysky2/pulseaudio-ctl) for volume control (`Mod+{KP_Add|KP_Subtract|KP_Multiply}`)
 - __ibus__ for Chinese input (`Ctrl+Space`)
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
(Optional) link the wallpaper directory as the source of randomized wallpapers. If you skip this step,
the default wallpaper will be used.
```
$ ln -s ~/Pictures/wallpapers ~/.config/awesome/runtime/wallpapers
```

## Screenshots ##

Vertically split, with the layout menu shown at the top-right:

<img src="https://github.com/zhangkun83/awesome-config/blob/master/screenshots/2-split.jpg" width="640">

Tiling windows in the background, with a window floating on top.  The
battery and wifi status are shown as notification by pressing the
`X86Tools` key:

<img src="https://github.com/zhangkun83/awesome-config/blob/master/screenshots/2-floating-on-top.jpg" width="640">

The floating layout. The blue bottom bar can be used to move (left button) and resize (right button) the window.

<img src="https://github.com/zhangkun83/awesome-config/blob/master/screenshots/2-floating.jpg" width="640">
