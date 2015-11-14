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
local wibox = require("wibox")

local floatingWindowAlwaysOnTop = true

function raise_focus()
  if client.focus then client.focus:raise() end
end

function run_shell_command(command)
    awful.util.spawn_with_shell(command)
end

function start_if_absent(name, command)
    run_shell_command(config_home .. "bin/start_if_absent.sh " .. name .. " " .. command)
end

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

config_home = os.getenv("HOME") .. "/.config/awesome/"
titlebar_height = 24
terminal = "xfce4-terminal"

-- {{{ provides the following variables / functions
--- * mythememod
--- * myawesomemenu
--- * mywiboxprops
--- * mykeybindings
--- * myautostarts
dofile(config_home .. "current_profile.lua")
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
os.execute("cat " .. config_home .. "theme/theme.lua " .. mythememod ..
    " > " .. config_home .. "theme/theme-generated.lua")
beautiful.init(config_home .. "theme/theme-generated.lua")

-- This is used later as the default terminal and editor to run.
--terminal = "x-terminal-emulator"
-- ZK: changed default terminal
editor = os.getenv("EDITOR") or "editor"

-- Table of layouts to cover with awful.layout.inc, order matters.
-- ZK: removed unused layouts
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.tile.bottom,
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "compositor", {
                                        { "on", config_home .. "bin/compositor.sh true" },
                                        { "off", config_home .. "bin/compositor.sh false" } } },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock(" %a %b %d, %H:%M ", 1)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1,
                        function (t)
                            awful.tag.viewonly(t)
                            raise_focus()
                        end),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                                  raise_focus()
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
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              raise_focus()
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              raise_focus()
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ prompt = " [Run]: " })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(
        s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox(awful.util.table.join({ position = "bottom", screen = s }, mywiboxprops))
    mywibox[s].border_color = "#434750"

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    -- if s == 1 then right_layout:add(wibox.widget.systray()) end
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
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local saved_tags_file = config_home .. "saved_tags"

-- ZK: save tag names so that they survive after restart
function save_tag_names()
  local f = assert(io.open(saved_tags_file, "w"))
  local savedTags = tags[mouse.screen]
  for i = 1, table.getn(savedTags) do
    f:write(savedTags[i].name)
    f:write("\n")
  end
  f:close()
end

function restore_tag_names()
  local f = assert(io.open(saved_tags_file, "r"))
  local savedTags = tags[mouse.screen]
  for i = 1, table.getn(savedTags) do
    savedTags[i].name = f:read()
  end
  f:close()
end

function set_floating_for_all_clients(value)
    local clients = client.get(mouse.screen)
    for k,c in pairs(clients) do
        if (c:isvisible()) then
            awful.client.floating.set(c, value)
        end
    end
end

function float_and_center_window(c)
    awful.client.floating.set(c, true)
    local geo = c:geometry()
    local screen_geo = screen[mouse.screen].geometry
    local xpadding = screen_geo.width / 10
    local ypadding = screen_geo.height / 10
    geo.x = xpadding
    geo.width = screen_geo.width - 2 * xpadding
    geo.y = ypadding
    geo.height = screen_geo.height - 2 * ypadding
    c:geometry(geo)
end

-- Adjust a range [initial_offset, initial_offset + initial_length), so that it
-- fit in the range [0, limit), with the minimum padding on both sides
-- (min_padding1 and min_padding2) and a minimum length (min_length).
-- min_length has a higher
-- priority than min_paddings and limit.
-- Returns a table {offset, length}.
function get_sane_offset_and_length(initial_offset, initial_length,
  min_padding1, min_padding2, min_length, limit)
    local offset = initial_offset
    local length = initial_length
    if offset < min_padding1 then
        offset = min_padding1
    end
    if offset + length > limit - min_padding2 then
        length = limit - min_padding2 - offset
    end
    if length < min_length then
        length = min_length
    end
    local result = {}
    result.offset = offset
    result.length = length
    return result
end

function place_window_sanely(c)
  local screen_geo = screen[mouse.screen].geometry
  local geo = c:geometry()
  local xgeo = get_sane_offset_and_length(
      geo.x, geo.width, 0, 0, screen_geo.width / 10, screen_geo.width)
  local ygeo = get_sane_offset_and_length(
      geo.y, geo.height, 10, beautiful.menu_height + 10,
      screen_geo.height / 10, screen_geo.height)
  geo.x = xgeo.offset
  geo.width = xgeo.length
  geo.y = ygeo.offset
  geo.height = ygeo.length
  c:geometry(geo)
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",
        function ()
            awful.tag.viewprev()
            raise_focus()
        end),
    awful.key({ modkey,           }, "Right",
        function ()
            awful.tag.viewnext()
            raise_focus()
        end),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            raise_focus()
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            raise_focus()
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            raise_focus()
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
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

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
    awful.key({ modkey, "Shift" }, "=",
              function ()
                  awful.prompt.run({ prompt = " [Rename tag]: " },
                  mypromptbox[mouse.screen].widget,
                  function (s)
                    local tag = awful.tag.selected(mouse.screen)
                    local index = awful.tag.getidx(tag)
                    if s == "" then
                      tag.name = index
                    else
                      tag.name = index .. ":" .. s
                    end
                    save_tag_names()
                  end)
              end),
    -- ZK: File manager
    awful.key({ modkey }, "]", function () awful.util.spawn("thunar") end),
    -- ZK: Youdao dict
    awful.key({ modkey }, "F10", function () awful.util.spawn(config_home .. "bin/youdao_dict.py") end),
    -- alsamixer
    awful.key({ modkey }, "F11", function () awful.util.spawn(config_home .. "bin/mixer.sh") end),
    -- ZK: Lock screen
    awful.key({ modkey }, "F12", function () awful.util.spawn(config_home .. "bin/xlock.sh") end),
    -- ZK: Open the cheat sheet
    awful.key({ modkey }, "/", function () awful.util.spawn(config_home .. "bin/cheatsheet.sh") end),
    awful.key({ modkey, "Control" }, "f", function() set_floating_for_all_clients(false) end),
    awful.key({ modkey, "Control", "Shift" }, "f", function() set_floating_for_all_clients(true) end),
    awful.key({ modkey }, "KP_Add", function() awful.util.spawn(config_home .. "bin/volume.sh up") end),
    awful.key({ modkey }, "KP_Subtract", function() awful.util.spawn(config_home .. "bin/volume.sh down") end),
    awful.key({ modkey }, "KP_Multiply", function() awful.util.spawn(config_home .. "bin/volume.sh mute") end),
    -- As we have removed mysystray, there no easy way to tell the current ibus input engine,
    -- We intercept the ibus hotkey and switch engine manually, so that we can display the current engine
    -- as an notification.
    awful.key({ "Control"}, "space", function () awful.util.spawn(config_home .. "bin/ibus-cycle-engine.sh") end),
    mykeybindings
)

-- Run whenver the floating status of a window changes
function on_floating_changed(c)
  if floatingWindowAlwaysOnTop then
    c.ontop = awful.client.floating.get(c)
    raise_focus()
  end
end

clientkeys = awful.util.table.join(
    -- awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,  },          "f",      awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "space", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
            raise_focus()
        end),
    awful.key({ modkey,           }, "p",      float_and_center_window),
    awful.key({ modkey,           }, "m",
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
                            raise_focus()
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                          raise_focus()
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                          raise_focus()
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                          raise_focus()
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
                     keys = clientkeys,
                     floating = true,
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
client.connect_signal("manage", function (c, startup)
    c:connect_signal("property::floating", on_floating_changed)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.under_mouse(c)
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    -- Create titlebar
    if c.type == "normal" or c.type == "dialog" or c.type == "utility" then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        --right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        --right_layout:add(awful.titlebar.widget.stickybutton(c))
        --right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c, { size = titlebar_height }):set_widget(layout)
        awful.titlebar.show(c)

        -- At least, make space for the window title, and do not extend over
        -- the borders of the screen
        place_window_sanely(c)
    end
    on_floating_changed(c)
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- }}}

-- ZK: Change key repeat rate
os.execute("xset r rate 220 30")
-- ZK: Make mouse move slower
os.execute("xset m 1/5 10")

start_if_absent("xscreensaver", "xscreensaver")
run_shell_command(config_home .. "bin/restart_ibus.sh")

myautostarts()

restore_tag_names()
