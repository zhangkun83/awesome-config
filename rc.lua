-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

local hideTitleBarWhenTiling = false

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
    awesome.add_signal("debug::error", function (err)
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
terminal = "xfce4-terminal"
cheatsheet_command = "xterm -geometry 66x37+800+300 -fa 'Monospace' -fs 11 -e 'less .config/awesome/cheatsheet.txt'"


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
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

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
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox(awful.util.table.join({ position = "bottom", screen = s }, mywiboxprops))
    mywibox[s].border_color = "#434750"
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
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
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- ZK: Prompt to rename the current tag
    awful.key({ modkey, "Shift" }, "=",
              function ()
                  awful.prompt.run({ prompt = "Rename tag: " },
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
    -- ZK: Lock screen
    awful.key({ modkey }, "F12", function () awful.util.spawn(config_home .. "bin/xlock.sh") end),
    -- ZK: Open the cheat sheet
    awful.key({ modkey }, "/", function () awful.util.spawn(cheatsheet_command) end),
    mykeybindings
)

-- ZK: Only show the title bar when the window is floating
function update_titlebar_status(c)
  if (not hideTitleBarWhenTiling) or awful.client.floating.get(c) then
    if not c.titlebar then awful.titlebar.add(c, { modkey = modkey, height = 24 }) end
  else
    if c.titlebar then awful.titlebar.remove(c) end
  end
end

clientkeys = awful.util.table.join(
    -- awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,  },          "f",      awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "space", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
            raise_focus()
        end),
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
client.add_signal("manage", function (c, startup)
    c:add_signal("property::floating", update_titlebar_status)

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

        -- At least, make space for the window title
        local geometry = c:geometry()
        if geometry.y < 50 then
          geometry.y = 50
        end
        c:geometry(geometry)
    end
    update_titlebar_status(c)
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- }}}

-- ZK: Change key repeat rate
os.execute("xset r rate 220 30")
-- ZK: Make mouse move slower
os.execute("xset m 1/5 10")

start_if_absent("gnome-sound-applet", "gnome-sound-applet")
start_if_absent("xscreensaver", "xscreensaver")
start_if_absent("ibus-daemon", "ibus-daemon -d")

myautostarts()

restore_tag_names()
