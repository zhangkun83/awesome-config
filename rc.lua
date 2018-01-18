-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local window_move_step = 50
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
titlebar_font = "Liberation Sans Bold 10"
titlebar_height_top = 20
titlebar_height_bottom = 12
titlebar_height_side = 5
titlebar_color_side = beautiful.bg_focus

aal = require("aal")
zk = require("zk")

terminal = zk.config_home .. "bin/urxvt.sh"
-- {{{ provides the following variables / functions
--- * mythememod
--- * myawesomemenu
--- * mywiboxprops
--- * mykeybindings
--- * myautostarts
--- * mycustomwidgets
dofile(zk.config_home .. "runtime/current_profile.lua")
-- }}}

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
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Profile can override parts of the theme
if mythememod then
   for k,v in pairs(mythememod) do
      beautiful.get()[k] = v
   end
end

function layoutMaximized()
   awful.layout.set(awful.layout.suit.max)
   zk.refresh_titlebars_all_clients()
end

function layoutHSplit()
   awful.layout.set(awful.layout.suit.tile.bottom)
   zk.refresh_titlebars_all_clients()
end

function layoutVSplit()
   awful.layout.set(awful.layout.suit.tile)
   zk.refresh_titlebars_all_clients()
end

function layoutFloating()
   awful.layout.set(awful.layout.suit.floating)
   -- Floating all clients will restore their positions when they were
   -- previously floating, which is favorable here.
   zk.set_floating_for_all_clients(true)
   -- But we don't really need them to be in floating state.
   zk.set_floating_for_all_clients(false)
   zk.refresh_titlebars_all_clients()
end

layoutMenu = awful.menu({ items = {
                             { "maximized", layoutMaximized, beautiful.layout_max },
                             { "horizontal split", layoutHSplit, beautiful.layout_tilebottom},
                             { "vertical split", layoutVSplit, beautiful.layout_tile},
                             { "floating", layoutFloating, beautiful.layout_floating}}})

local tasklistMenuTarget = nil
local tasklistMenu = awful.menu({ items = {
                                     { "dock / float", function()
                                          aal.set_client_floating(tasklistMenuTarget, not aal.is_client_floating(tasklistMenuTarget))
                                          zk.raise_focus_client()
                                                       end},
                                     { "float canonically", function()
                                          float_window_canonically(tasklistMenuTarget)
                                                       end},
                                     { "minimize", function()
                                          zk.minimize_client(tasklistMenuTarget)
                                                   end},
                                     { "close", function()
                                          if tasklistMenuTarget then
                                             tasklistMenuTarget:kill()
                                          end
                                                end}}})

-- This is used later as the default terminal and editor to run.
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.max,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

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

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock(" %I:%M %p ", 1)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1,
                        function(t)
                           t:view_only()
                           zk.raise_focus_client()
                        end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  zk.raise_focus_client()
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 2, function (c)
                                     c.minimized = true
                                     zk.raise_focus_client()
                                          end),
                     awful.button({ }, 3, function (c)
                                     tasklistMenuTarget = c
                                     awful.menu.toggle(tasklistMenu)
                                          end))

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.menu.toggle(layoutMenu) end),
                           awful.button({ }, 3, function () awful.menu.toggle(layoutMenu) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, zk.task_list_filter_exclude_minimized, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar(awful.util.table.join({ position = "top", screen = s}, mywiboxprops))

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
           layout = wibox.layout.fixed.horizontal,
           mytextclock,
           s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
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
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "/",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey,           }, "s",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "a",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "s", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "a", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "s", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "a", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab", function() zk.next_client_by_floating(false) end,
        {description = "next docked client", group = "client"}),
    awful.key({ modkey,           }, "`", function() zk.next_client_by_floating(true) end,
        {description = "next floating client", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,           }, "F1",    layoutMaximized,
              {description = "maximized", group = "layout"}),
    awful.key({ modkey,           }, "F2",    layoutHSplit,
              {description = "horizontal split", group = "layout"}),
    awful.key({ modkey,           }, "F3",    layoutVSplit,
              {description = "vertical split", group = "layout"}),
    awful.key({ modkey,           }, "F4",    layoutFloating,
              {description = "floating", group = "layout"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "d",     function () zk.set_floating_for_all_clients(false) end,
              {description = "dock all clients", group = "client"}),
    awful.key({ modkey, "Shift"   }, "f",     function () zk.set_floating_for_all_clients(true) end,
              {description = "float all clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- ZK: Prompt to rename the current tag
    awful.key({ modkey, "Shift" }, "=", zk.rename_tag,
              {description = "rename current tag", group = "tag"}),
    -- ZK: File manager
    awful.key({ modkey }, "]", function () awful.util.spawn("thunar") end,
              {description = "file manager", group = "launcher"}),
    -- ZK: Youdao dict
    awful.key({ modkey }, "F10", function () awful.util.spawn(zk.config_home .. "bin/youdao_dict.py") end,
              {description = "dictionary", group = "launcher"}),
    -- pulse audio control panel
    awful.key({ modkey }, "F11", function () awful.util.spawn("pavucontrol") end,
              {description = "volume control", group = "launcher"}),
    -- ZK: Lock screen
    awful.key({ modkey }, "F12", function () aal.spawn(zk.config_home .. "bin/xlock.sh") end,
              {description = "lock the screen", group = "awesome"}),
    awful.key({ modkey, "Shift" }, "F12", function () aal.spawn(zk.config_home .. "bin/sleepnlock.sh") end,
              {description = "lock the screen and sleep", group = "awesome"}),
    mykeybindings
)

clientkeys = gears.table.join(
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey,           }, "f",  function(c) aal.set_client_floating(c, true) end,
              {description = "float", group = "client"}),
    awful.key({ modkey,           }, "d",  function(c) aal.set_client_floating(c, false) end,
              {description = "dock", group = "client"}),
    awful.key({ modkey, "Control" }, "space", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "n", zk.minimize_client,
              {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "p",      float_window_canonically,
              {description = "float window canonically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "p",      float_window_canonically_reverse,
              {description = "float window canonically (reverse direction)", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}),
    awful.key({ modkey }, "Up",  function (c) zk.change_window_geometry(0, -window_move_step, 0, 0, c) end),
    awful.key({ modkey }, "Down",  function (c) zk.change_window_geometry(0, window_move_step, 0, 0, c) end),
    awful.key({ modkey }, "Left",  function (c) zk.change_window_geometry(-window_move_step, 0, 0, 0, c) end),
    awful.key({ modkey }, "Right",  function (c) zk.change_window_geometry(window_move_step, 0, 0, 0, c) end),
    awful.key({ modkey, "Shift" }, "Up",  function (c) zk.change_window_geometry(0, 0, 0, -window_move_step, c) end),
    awful.key({ modkey, "Shift" }, "Down",  function (c) zk.change_window_geometry(0, 0, 0, window_move_step, c) end),
    awful.key({ modkey, "Shift" }, "Left",  function (c) zk.change_window_geometry(0, 0, -window_move_step, 0, c) end),
    awful.key({ modkey, "Shift" }, "Right",  function (c) zk.change_window_geometry(0, 0, window_move_step, 0, c) end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end)
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     floating = true,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     titlebars_enabled = true,
                     -- ZK: otherwise terminal window may insist on multiples of font size
                     -- and its size may not be exactly what the WM set it to be.
                     size_hints_honor = false,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },
    -- ZK: do not show border and titlebar for xfce4-panel
    { rule = { type = "dock" },
      properties = {
         border_width = 0,
         titlebars_enabled = false
      }},
    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},
    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
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

    local titlewidget = awful.titlebar.widget.titlewidget(c)
    titlewidget.font = titlebar_font
    awful.titlebar(c, {position = "top", size = titlebar_height_top}) : setup {
        { -- Left
           widget = awful.titlebar.widget.iconwidget(c),
        },
        { -- Middle
            { -- Title
               align  = "center",
               widget = titlewidget
            },
            layout  = wibox.layout.flex.horizontal
        },
        buttons = buttons,
        layout = wibox.layout.align.horizontal
    }

    awful.titlebar(c, {position = "bottom", size = titlebar_height_bottom}) : setup {
        { -- No title
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        layout = wibox.layout.flex.horizontal
    }

    -- Side titlebars are used to indicate ontop status
    awful.titlebar(c, {position = "left", size = titlebar_height_side, bg_focus = titlebar_color_side}) : setup {
        layout = wibox.layout.flex.vertical
    }
    awful.titlebar(c, {position = "right", size = titlebar_height_side, bg_focus = titlebar_color_side}) : setup {
        layout = wibox.layout.flex.vertical
    }
    zk.refresh_titlebars(c)
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("manage", zk.client_manage_hook)
-- }}}

zk.post_starts()
myautostarts()

-- ZK: To allow xfce4 taskbar to restore minimized windows. xfce4
-- taskbar would "activate" the minimized window when clicked, but
-- awesome by default only mark the window as urgent without restoring
-- it (see https://github.com/awesomeWM/awesome/issues/927)
client.connect_signal("request::activate",
                      function(c)
                         -- Avoid setting c.minimized = false if it's
                         -- already false, to prevent C stack
                         -- overflow.
                         if c.minimized then
                            c.minimized = false
                            client.focus = c
                            zk.raise_focus_client()
                         end
                      end)

-- ZK: generalized hotkeys
hotkeys_popup.add_hotkeys(
   {
      ["client"] = {
         {
            modifiers = {modkey},
            keys = {
               ["&lt;arrow&gt;"] = "move client"
            }
         },
         {
            modifiers = {modkey, "Shift"},
            keys = {
               ["&lt;arrow&gt;"] = "resize client"
            }
         }
      },
      ["tag"] = {
         {
            modifiers = {modkey},
            keys = {
               ["&lt;num&gt;"] = "view tag"
            }
         },
         {
            modifiers = {modkey, "Control"},
            keys = {
               ["&lt;num&gt;"] = "toggle tag"
            }
         },
         {
            modifiers = {modkey, "Shift"},
            keys = {
               ["&lt;num&gt;"] = "move focused client to tag"
            }
         },
         {
            modifiers = {modkey, "Control", "Shift"},
            keys = {
               ["&lt;num&gt;"] = "toggle focused client on tag"
            }
         }
      }
   })
