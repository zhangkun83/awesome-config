-- Standard awesome library
local gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
-- Widget and layout library
wibox = require("wibox")

aal = require("aal")
zk = require("zk")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

titlebar_height = 12
terminal = "xfce4-terminal"
local window_move_step = 50
cheatsheet_command = zk.config_home .. "bin/cheatsheet.sh"

-- {{{ provides the following variables / functions
--- * mythememod
--- * myawesomemenu
--- * mywiboxprops
--- * mykeybindings
--- * myautostarts
--- * mycustomwidgets
dofile(zk.config_home .. "runtime/current_profile.lua")
-- }}}

beautiful.init(zk.config_home .. "theme/theme.lua")

-- Profile can override parts of the theme
if mythememod then
   for k,v in pairs(mythememod) do
      beautiful.get()[k] = v
   end
end

function layoutMaximized()
   awful.layout.set(awful.layout.suit.max)
end

function layoutHSplit()
   awful.layout.set(awful.layout.suit.tile.bottom)
end

function layoutVSplit()
   awful.layout.set(awful.layout.suit.tile)
end

function layoutFloating()
   awful.layout.set(awful.layout.suit.floating)
   -- Floating all clients will restore their positions when they were
   -- previously floating, which is favorable here.
   zk.set_floating_for_all_clients(true)
   -- But we don't really need them to be in floating state.
   zk.set_floating_for_all_clients(false)
end

layoutMenu = awful.menu({ items = {
                             { "maximized", layoutMaximized, beautiful.layout_max },
                             { "horizontal split", layoutHSplit, beautiful.layout_tilebottom},
                             { "vertical split", layoutVSplit, beautiful.layout_tile},
                             { "floating", layoutFloating, beautiful.layout_floating}}})

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, s, awful.layout.suit.floating)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "web browser", zk.config_home .. "bin/chrome-default-user.sh"},
                                    { "file manager", "thunar"},
                                    { "dictionary", zk.config_home .. "bin/youdao_dict.py" },
                                    { "open terminal", terminal },
                                    { "switch wallpaper", zk.config_home .. "bin/prepare-wallpaper.sh" }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock("%H:%M ", 1)
mytextclock:buttons(awful.button({ }, 1, function() awful.util.spawn(zk.config_home .. "bin/show-calendar-notification.sh") end))

separatorbox = wibox.widget.textbox("│")
myibusbox = wibox.widget.textbox("?ibus?")

function move_and_switch_to_tag(t)
   awful.client.movetotag(t)
   awful.tag.viewonly(t)
end

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1,
                        function (t)
                            awful.tag.viewonly(t)
                            zk.raise_focus_client()
                        end),
                    awful.button({ modkey }, 1, move_and_switch_to_tag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                                  zk.raise_focus_client()
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 2, function ()
                                     awful.client.focus.byidx(-1)
                                     zk.raise_focus_client()
                                          end),
                     awful.button({ }, 3, function ()
                                     awful.client.focus.byidx(1)
                                     zk.raise_focus_client()
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ prompt = " [Run]: " })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.menu.toggle(layoutMenu) end),
                           awful.button({ }, 3, function () awful.menu.toggle(layoutMenu) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(
        s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox(awful.util.table.join({ position = "top", screen = s }, mywiboxprops))
    mywibox[s].border_color = "#434750"

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()

    right_layout:add(separatorbox)

    if mycustomwidgets then
       for _, v in ipairs(mycustomwidgets) do
          right_layout:add(v)
          right_layout:add(separatorbox)
       end
    end

    right_layout:add(myibusbox)
    right_layout:add(separatorbox)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- }}}

-- Float a window and apply a canonical geometry
-- If not currently with any canonical geometry, will
-- use the first one.  Otherwise, will use the next one.
function float_window_canonically(c)
  zk.float_window_canonically(c, 1)
end

-- Float a window and apply a canonical geometry
-- If not currently with any canonical geometry, will
-- use the first one.  Otherwise, will use the previous one.
function float_window_canonically_reverse(c)
  zk.float_window_canonically(c, -1)
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "s",
        function ()
            awful.client.focus.byidx( 1)
            zk.raise_focus_client()
        end),
    awful.key({ modkey,           }, "a",
        function ()
            awful.client.focus.byidx(-1)
            zk.raise_focus_client()
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "s", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "a", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "s", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "a", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            zk.raise_focus_client()
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    --awful.key({ modkey, "Control" }, "r", awesome.restart),
    --awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "F1",    layoutMaximized),
    awful.key({ modkey,           }, "F2",    layoutHSplit),
    awful.key({ modkey,           }, "F3",    layoutVSplit),
    awful.key({ modkey,           }, "F4",    layoutFloating),

    awful.key({ modkey, "Control" }, "n",
              function()
                local c = awful.client.restore()
                if c then
                  client.focus = c
                  zk.raise_focus_client()
                end
              end),

    awful.key({ modkey, "Shift" }, "n", zk.minimize_all_floating_clients),
    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = " [Run Lua code]: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- ZK: Prompt to rename the current tag
    awful.key({ modkey, "Shift" }, "=", zk.rename_tag),
    -- ZK: File manager
    awful.key({ modkey }, "]", function () awful.util.spawn("thunar") end),
    -- ZK: Youdao dict
    awful.key({ modkey }, "F10", function () awful.util.spawn(zk.config_home .. "bin/youdao_dict.py") end),
    -- pulse audio control panel
    awful.key({ modkey }, "F11", function () awful.util.spawn("pavucontrol") end),
    -- ZK: Lock screen
    awful.key({ modkey }, "F12", function () awful.util.spawn(zk.config_home .. "bin/xlock.sh") end),
    awful.key({ modkey, "Shift" }, "F12", function () awful.util.spawn(zk.config_home .. "bin/sleepnlock.sh") end),
    -- ZK: Open the cheat sheet
    awful.key({ modkey }, "/", function () awful.util.spawn(cheatsheet_command) end),
    awful.key({ modkey, "Shift" }, "d", function() zk.set_floating_for_all_clients(false) end),
    awful.key({ modkey, "Shift" }, "f", function() zk.set_floating_for_all_clients(true) end),
    awful.key({ modkey }, "F7", function() awful.util.spawn(zk.config_home .. "bin/volume.sh up") end),
    awful.key({ }, "XF86AudioRaiseVolume", function() awful.util.spawn(zk.config_home .. "bin/volume.sh up") end),
    awful.key({ modkey }, "F6", function() awful.util.spawn(zk.config_home .. "bin/volume.sh down") end),
    awful.key({ }, "XF86AudioLowerVolume", function() awful.util.spawn(zk.config_home .. "bin/volume.sh down") end),
    awful.key({ modkey }, "F5", function() awful.util.spawn(zk.config_home .. "bin/volume.sh mute") end),
    awful.key({ }, "XF86AudioMute", function() awful.util.spawn(zk.config_home .. "bin/volume.sh mute") end),
    awful.key({ }, "XF86MonBrightnessUp", function() awful.util.spawn(zk.config_home .. "bin/backlight.sh up") end),
    awful.key({ }, "XF86MonBrightnessDown", function() awful.util.spawn(zk.config_home .. "bin/backlight.sh down") end),
    -- As we have removed mysystray, there no easy way to tell the current ibus input engine,
    -- We intercept the ibus hotkey and switch engine manually, so that we can display the current engine
    -- as an notification.
    awful.key({ modkey }, "space", function() awful.util.spawn(zk.config_home .. "bin/ibus-cycle-engine.sh") end),
    awful.key({ modkey }, ",", function () awful.util.spawn(zk.config_home .. "bin/ibus-cycle-engine.sh 0") end),
    awful.key({ modkey }, ".", function () awful.util.spawn(zk.config_home .. "bin/ibus-cycle-engine.sh 1") end),
    mykeybindings
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,  },          "d",      function (c)
                 if awful.layout.get(c.screen) == awful.layout.suit.floating then
                    layoutMaximized()
                 end
                 awful.client.floating.set(c, false)
                                               end),
    awful.key({ modkey,  },          "f",      function (c) awful.client.floating.set(c, true) end),
    awful.key({ modkey, "Control" }, "space", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    --awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            c.minimized = true
            zk.raise_focus_client()
        end),
    awful.key({ modkey,           }, "p",      float_window_canonically),
    awful.key({ modkey, "Shift"   }, "p",      float_window_canonically_reverse),
    -- Resizing the window by keyboard
    awful.key({ modkey, "Shift" }, "KP_Up",  function (c) zk.change_window_geometry(0, 0, 0, -window_move_step, c) end),
    awful.key({ modkey, "Shift" }, "Up",  function (c) zk.change_window_geometry(0, 0, 0, -window_move_step, c) end),
    awful.key({ modkey, "Shift" }, "KP_Down",  function (c) zk.change_window_geometry(0, 0, 0, window_move_step, c) end),
    awful.key({ modkey, "Shift" }, "Down",  function (c) zk.change_window_geometry(0, 0, 0, window_move_step, c) end),
    awful.key({ modkey, "Shift" }, "KP_Left",  function (c) zk.change_window_geometry(0, 0, -window_move_step, 0, c) end),
    awful.key({ modkey, "Shift" }, "Left",  function (c) zk.change_window_geometry(0, 0, -window_move_step, 0, c) end),
    awful.key({ modkey, "Shift" }, "KP_Right",  function (c) zk.change_window_geometry(0, 0, window_move_step, 0, c) end),
    awful.key({ modkey, "Shift" }, "Right",  function (c) zk.change_window_geometry(0, 0, window_move_step, 0, c) end),
    awful.key({ modkey, "Shift" }, "KP_Home",  function (c) zk.change_window_geometry(0, 0, -window_move_step, -window_move_step, c) end),
    awful.key({ modkey, "Shift" }, "KP_Next",  function (c) zk.change_window_geometry(0, 0, window_move_step, window_move_step, c) end),
    awful.key({ modkey, "Shift" }, "KP_End",  function (c) zk.change_window_geometry(0, 0, -window_move_step, window_move_step, c) end),
    awful.key({ modkey, "Shift" }, "KP_Prior",  function (c) zk.change_window_geometry(0, 0, window_move_step, -window_move_step, c) end),
    -- Moving the window by keyboard
    awful.key({ modkey }, "KP_Up",  function (c) zk.change_window_geometry(0, -window_move_step, 0, 0, c) end),
    awful.key({ modkey }, "Up",  function (c) zk.change_window_geometry(0, -window_move_step, 0, 0, c) end),
    awful.key({ modkey }, "KP_Down",  function (c) zk.change_window_geometry(0, window_move_step, 0, 0, c) end),
    awful.key({ modkey }, "Down",  function (c) zk.change_window_geometry(0, window_move_step, 0, 0, c) end),
    awful.key({ modkey }, "KP_Left",  function (c) zk.change_window_geometry(-window_move_step, 0, 0, 0, c) end),
    awful.key({ modkey }, "Left",  function (c) zk.change_window_geometry(-window_move_step, 0, 0, 0, c) end),
    awful.key({ modkey }, "KP_Right",  function (c) zk.change_window_geometry(window_move_step, 0, 0, 0, c) end),
    awful.key({ modkey }, "Right",  function (c) zk.change_window_geometry(window_move_step, 0, 0, 0, c) end),
    awful.key({ modkey }, "KP_Home",  function (c) zk.change_window_geometry(-window_move_step, -window_move_step, 0, 0, c) end),
    awful.key({ modkey }, "KP_Next",  function (c) zk.change_window_geometry(window_move_step, window_move_step, 0, 0, c) end),
    awful.key({ modkey }, "KP_End",  function (c) zk.change_window_geometry(-window_move_step, window_move_step, 0, 0, c) end),
    awful.key({ modkey }, "KP_Prior",  function (c) zk.change_window_geometry(window_move_step, -window_move_step, 0, 0, c) end),
    -- Placing the window at pivot points
    awful.key({ modkey, "Control" }, "KP_Up",  function (c) zk.place_window_at_pivot(0, -1, c) end),
    awful.key({ modkey, "Control" }, "KP_Down",  function (c) zk.place_window_at_pivot(0, 1, c) end),
    awful.key({ modkey, "Control" }, "KP_Left",  function (c) zk.place_window_at_pivot(-1, 0, c) end),
    awful.key({ modkey, "Control" }, "KP_Right",  function (c) zk.place_window_at_pivot(1, 0, c) end),
    awful.key({ modkey, "Control" }, "KP_Home",  function (c) zk.place_window_at_pivot(-1, -1, c) end),
    awful.key({ modkey, "Control" }, "KP_Next",  function (c) zk.place_window_at_pivot(1, 1, c) end),
    awful.key({ modkey, "Control" }, "KP_End",  function (c) zk.place_window_at_pivot(-1, 1, c) end),
    awful.key({ modkey, "Control" }, "KP_Prior",  function (c) zk.place_window_at_pivot(1, -1, c) end),
    awful.key({ modkey, "Control" }, "KP_Begin", function (c) zk.place_window_at_pivot(0, 0, c) end),
    awful.key({ modkey, "Control" }, "Up",  function (c) zk.move_window_to_pivot(0, -1, c) end),
    awful.key({ modkey, "Control" }, "Down",  function (c) zk.move_window_to_pivot(0, 1, c) end),
    awful.key({ modkey, "Control" }, "Right",  function (c) zk.move_window_to_pivot(1, 0, c) end),
    awful.key({ modkey, "Control" }, "Left",  function (c) zk.move_window_to_pivot(-1, 0, c) end),
    awful.key({ modkey }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 10
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(10, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                            zk.raise_focus_client()
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                          zk.raise_focus_client()
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          move_and_switch_to_tag(tags[client.focus.screen][i])
                          zk.raise_focus_client()
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                          zk.raise_focus_client()
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     floating = true,
                     keys = clientkeys,
                     size_hints_honor = false,
                     buttons = clientbuttons },
      -- ZK: new windows are set as slave, so the existing master window can stay master
      callback = awful.client.setslave },
    -- ZK: I use xterm to launch short-lived console programs. This makes the
    -- window always on top.
    -- HOW-TO: use xprop to get window properties. "class" is the second value in WM_CLASS.
    { rule = { class = "XTerm" },
      properties = { ontop = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("manage", zk.client_manage_hook)
-- }}}

myautostarts()
zk.post_starts()
