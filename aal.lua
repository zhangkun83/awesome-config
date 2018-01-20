-- The Awesome Abstract Layer that abstracts out the awesome API
local awful = require("awful")
local tag = require("awful.tag")
local aal = {}

-- Returns true if the client's floating flag is set
function aal.is_client_floating(c)
   return c.floating
end

-- Change the floating flag of a client
function aal.set_client_floating(c, floating)
   -- Dock windows are always floating. Do not change it.
   if (not aal.is_panel(c)) then
      -- Restore the geometry when the client was previously floating
      local floating_geometry = awful.client.property.get(c, 'floating_geometry')
      c.floating = floating
      c:geometry(floating_geometry)
   end
end

-- Set the client's ontop flag
function aal.set_client_ontop(c, ontop)
   c.ontop = ontop
end

function aal.is_client_ontop(c)
   return c.ontop
end

-- Returns true if the client is in floating layout
function aal.is_in_floating_layout(c)
   return awful.layout.get(c.screen) == awful.layout.suit.floating
end

function aal.is_in_maximized_layout(c)
   return awful.layout.get(c.screen) == awful.layout.suit.max
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

function aal.is_panel(c)
   return c.type == "dock"
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

function aal.create_notification(text, position, font)
   return naughty.notify(
      {text = text, position = position, font = font, timeout = 10})
end

function aal.delete_notification(notification)
   naughty.destroy(notification)
end

function aal.spawn(command)
   awful.spawn(command)
end

function aal.run_shell_command(command)
   awful.spawn.with_shell(command)
end

function aal.get_minimized_clients_current_tag()
   local s = mouse.screen
   local cls = client.get(s)
   local tags = tag.selectedlist(s)
   local mcls = {}
   local i = 0
   for k, c in pairs(cls) do
      local ctags = c:tags()
      if c.minimized then
         for k, t in ipairs(tags) do
            if awful.util.table.hasitem(ctags, t) then
               i = i + 1
               mcls[i] = c
               break
            end
         end
      end
   end
   return mcls
end

function aal.quit_awesome()
   awesome.quit()
end

return aal
