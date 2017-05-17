-- The Awesome Abstract Layer that abstracts out the awesome API
local aal = {}

-- Returns true if the client's floating flag is set
function aal.is_client_floating(c)
   return awful.client.floating.get(c)
end

-- Change the floating flag of a client
function aal.set_client_floating(c, floating)
   awful.client.floating.set(c, floating)
end

-- Set the client's ontop flag
function aal.set_client_ontop(c, ontop)
   c.ontop = ontop
end

-- Returns true if the client is in floating layout
function aal.is_in_floating_layout(c)
   return awful.layout.get(c.screen) == awful.layout.suit.floating
end

function aal.get_client_geometry(c)
   return c:geometry()
end

function aal.set_client_geometry(c, geo)
   c:geometry(geo)
end

-- Get the workarea geometry that the given client is in
function aal.get_workarea(c)
   return screen[c.screen].workarea
end

function aal.should_have_title_bar(c)
   return c.type == "normal" or c.type == "dialog" or c.type == "utility"
end

function aal.get_focus_client()
   return client.focus
end

function aal.get_next_client(relative_idx, c)
   return awful.client.next(relative_idx, c)
end

function aal.focus_client(c)
   awful.client.focus.byidx(0, c)
end

function aal.create_title_bar(c)
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

   -- Create a layout without widgets, just to bind the mouse buttons
   local layout = wibox.layout.align.horizontal()
   layout:buttons(buttons)

   -- The titlebar position has to be passed to both titlebar() and titlebar.show(),
   -- otherwise the implementation will mess up.
   awful.titlebar(c, { size = titlebar_height, position = "bottom" }):set_widget(layout)
   awful.titlebar.show(c, "bottom")
end

function aal.create_notification(text, position, font)
   return naughty.notify(
      {text = text, position = position, font = font, timeout = 10})
end

function aal.delete_notification(notification)
   naughty.destroy(notification)
end

function aal.run_shell_command(command)
   awful.util.spawn_with_shell(command)
end

return aal
