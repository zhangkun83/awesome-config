aal = require("aal")
awful = require("awful")
gears = require("gears")
tasklist = require("awful.widget.tasklist")

local zk = {}

zk.config_home = gears.filesystem.get_configuration_dir()

local saved_tags_file = zk.config_home .. "runtime/saved_tags"

local function is_floating(c)
  return aal.is_in_floating_layout(c) or aal.is_client_floating(c)
end

-- Run whenver the floating status of a window changes
local function on_floating_changed(c)
   aal.set_client_ontop(c, aal.is_client_floating(c))
   zk.raise_focus_client()
   zk.refresh_titlebars(c)
end

local function geo_equals(g1, g2)
   -- Some applications, e.g., terminal emulators will snap their
   -- widths and heights to the integral multiples of character width
   -- and height.  Therefore we only check x and y, and ignore widths
   -- and height.
   return math.abs(g1.x - g2.x) < 2 and math.abs(g1.y - g2.y) < 2
end

-- Get the sign of the given number.
-- 1 for positive, -1 for negative, or 0.
-- If abs(a) < epsilon, return 0.
local function get_sign(a, epsilon)
   if math.abs(a) < epsilon then
      return 0
   end
   if a > 0 then
      return 1
   end
   return -1
end

-- Return one of the 9 pre-defined pivot geos of the client.
-- For example (h, v) = (0, 0) means center, (-1, 0) means center-left
-- (1, 1) means down-right.
local function get_pivot_geo(h, v, c)
   local geo = aal.get_client_geometry(c)
   -- geo doesn't count in the border size, but we want to include it when calculating
   -- the size of the window
   local client_width = geo.width + 2 * beautiful.border_width
   local client_height = geo.height + 2 * beautiful.border_width
   local workarea = aal.get_workarea(c)
   local win_center = {}
   win_center.x = workarea.width * (0.5 + h * 0.33)
   win_center.y = workarea.height * (0.5 + v * 0.33)
   geo.x = math.min(math.max(0, win_center.x - client_width / 2), workarea.width - client_width) + workarea.x
   geo.y = math.min(math.max(0, win_center.y - client_height / 2), workarea.height - client_height) + workarea.y
   return geo
end

-- Adjust a range [initial_offset, initial_offset + initial_length), so that it
-- fit in the range [0, limit), with the minimum padding on both sides
-- (min_padding1 and min_padding2) and a minimum length (min_length).
-- min_length has a higher
-- priority than min_paddings and limit.
-- Returns a table {offset, length}.
local function get_sane_offset_and_length(initial_offset, initial_length,
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

local function place_window_sanely(c)
   local screen_geo = aal.get_workarea(c)
   local geo = aal.get_client_geometry(c)
   local xgeo = get_sane_offset_and_length(
      geo.x, geo.width, 0, 0, screen_geo.width / 10, screen_geo.width)
   local ygeo = get_sane_offset_and_length(
      geo.y, geo.height, 10, beautiful.menu_height + 10,
      screen_geo.height / 10, screen_geo.height)
   geo.x = xgeo.offset
   geo.width = xgeo.length
   geo.y = ygeo.offset
   geo.height = ygeo.length
   aal.set_client_geometry(c, geo)
end

local function restore_tag_names()
  local f = assert(io.open(saved_tags_file, "r"))
  local screen = awful.screen.focused()
  for tag in gears.table.iterate(screen.tags, function(i) return true end) do
    tag.name = f:read()
  end
  f:close()
end

-- Save tag names so that they survive after restart
local function save_tag_names()
  local f = assert(io.open(saved_tags_file, "w"))
  local screen = awful.screen.focused()
  for tag in gears.table.iterate(screen.tags, function(i) return true end) do
    f:write(tag.name)
    f:write("\n")
  end
  f:close()
end

local function get_pos_value(screen_geo, c)
   local geo = c:geometry()
   return geo.x * screen_geo.height + geo.y
end

-- Choose between c1 and c2, return the one that has smaller
-- horizontal distance to the pivot, dir == -1 means left to the
-- pivot, == 1 means right to the pivot.
local function get_closer_client(pivot, dir, c1, c2)
   local s = mouse.screen.geometry
   local v1 = get_pos_value(s, c1)
   local v2 = get_pos_value(s, c2)
   local vp = get_pos_value(s, pivot)
   -- For the same pivot, c1, c2, the answer with dir == 1 is always
   -- the opposite of the answer with dir == -1.  We simply swap the
   -- positions of c1 and c2 and assume dir == 1 from now on.
   if dir == -1 then
      local t = g1
      g1 = g2
      g2 = t
   end

   -- Calculate distances
   local d1 = v1 - vp
   local d2 = v2 - vp
   while d1 < 0 do
      d1 = d1 + s.width * s.height
   end
   while d2 < 0 do
      d2 = d2 + s.width * s.height
   end

   if d1 <= d2 then
      return c1
   else
      return c2
   end
end

function zk.refresh_titlebars(c)
   if not aal.is_panel(c) then
      if is_floating(c) then
         awful.titlebar.show(c, "top")
      else
         awful.titlebar.hide(c, "top")
      end
      if aal.is_in_maximized_layout(c) and not aal.is_client_floating(c) then
         awful.titlebar.hide(c, "bottom")
      else
         awful.titlebar.show(c, "bottom")
      end
      if aal.is_client_ontop(c) then
         awful.titlebar.show(c, "left")
         awful.titlebar.show(c, "right")
      else
         awful.titlebar.hide(c, "left")
         awful.titlebar.hide(c, "right")
      end
   end
end

function zk.refresh_titlebars_all_clients()
   local clients = client.get(mouse.screen)
   for k,c in pairs(clients) do
      if c:isvisible() then
         zk.refresh_titlebars(c)
      end
   end
end

function zk.client_manage_hook(c, startup)
  c:connect_signal("property::floating", on_floating_changed)

  if not startup then
    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.under_mouse(c)
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end

  -- New windows are always floating, but have "floating" state only when necessary.
  aal.set_client_floating(c, not aal.is_in_floating_layout(c))

  on_floating_changed(c)
end

function zk.rename_tag()
   awful.prompt.run({ prompt = "Name tag: " },
                    mouse.screen.mypromptbox.widget,
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
end

function zk.set_floating_for_all_clients(value)
    local clients = client.get(mouse.screen)
    for k,c in pairs(clients) do
       if c:isvisible() then
          aal.set_client_floating(c, value)
       end
    end
end

function zk.minimize_client(c)
   if not aal.is_panel(c) then
      c.minimized = true
      zk.raise_focus_client()
   end
end

function zk.menu_restore_client()
   local mcls = aal.get_minimized_clients_current_tag()
   local num = 0
   local items = {}
   local last_c = nil
   for i, c in pairs(mcls) do
      num = num + 1
      items[num] = {
         c.name,
         function()
            zk.restore_client(c)
         end,
         c.icon,
      }
      last_c = c
   end
   if num == 0 then
      return
   end
   if num == 1 then
      zk.restore_client(last_c)
      return
   end
   local menu = { items = items, theme = { width = "600", height = "32" }}
   awful.menu(menu):show()
end

function zk.minimize_all_other_floating_clients()
   local clients = client.get(mouse.screen)
   for k,c in pairs(clients) do
      if aal.is_client_floating(c) and (not aal.is_panel(c)) and (client.focus ~=c) then
         c.minimized = true
      end
   end
   zk.raise_focus_client()
end

function zk.restore_all_minimized_clients()
   local mcls = aal.get_minimized_clients_current_tag()
   for k, c in pairs(mcls) do
      zk.restore_client(c)
   end
end

function zk.restore_client(c)
   if not c.minimized then
      return
   end
   c.minimized = false
   client.focus = c
   zk.raise_focus_client()
end

-- Place the window at one of the 9 pre-defined pivot points on the screen
-- as defined by get_pivot_geo()
function zk.place_window_at_pivot(h, v, c)
  if not is_floating(c) then
    return
  end
  aal.set_client_geometry(c, get_pivot_geo(h, v, c))
end

-- Move the window to the closest pivot to the direction defined by
-- (dh, dv). d?==-1(1) means moving left(right) on that dimension. 0 means
-- no movement on that dimension.
function zk.move_window_to_pivot(dh, dv, c)
   if not is_floating(c) then
      return
   end
   local current_geo = aal.get_client_geometry(c)
   local screen_geo = aal.get_workarea(c)

   if dh ~= 0 then
      for h=-dh, dh, dh do
         local geo = get_pivot_geo(h, 0, c)
         if get_sign(geo.x - current_geo.x, 2) == dh then
            current_geo.x = geo.x
            break
         end
      end
   end
   if dv ~= 0 then
      for v=-dv, dv, dv do
         local geo = get_pivot_geo(0, v, c)
         if get_sign(geo.y - current_geo.y, 2) == dv then
            current_geo.y = geo.y
            break
         end
      end
   end
   aal.set_client_geometry(c, current_geo)
end

function zk.change_window_geometry(dx, dy, dw, dh, c)
   if not is_floating(c) then
      awful.client.incwfact(0.05 * get_sign(dw + dh, 0.1))
   else
      local geo = aal.get_client_geometry(c)
      local screen_geo = aal.get_workarea(c)
      geo.x = math.min(math.max(0, geo.x + dx), screen_geo.width - 50)
      geo.y = math.min(math.max(0, geo.y + dy), screen_geo.height - 50)
      geo.width = math.min(math.max(100, geo.width + dw), screen_geo.width)
      geo.height = math.min(math.max(100, geo.height + dh), screen_geo.height)
      aal.set_client_geometry(c, geo)
   end
end

function zk.float_window_canonically(c, dir)
  local was_floating = is_floating(c)
  if not was_floating then
    aal.set_client_floating(c, true)
  end
  local screen_geo = aal.get_workarea(c)
  local x_padding_step = screen_geo.width / 20
  local y_padding_step = screen_geo.height / 20
  local min_padding_step = math.min(x_padding_step, y_padding_step)
  local num_canonical_geos = 0
  -- Generate canonical geometries
  local canonical_geos = {}
  local geo = {}
  -- Two centered
  for i=1, 2 do
     geo = {}
     local xpadding = x_padding_step * 2 * i
     local ypadding = y_padding_step * (2 * i - 1)
     geo.x = xpadding
     geo.y = ypadding + screen_geo.y
     geo.width = screen_geo.width - 2 * xpadding
     geo.height = screen_geo.height - 2 * ypadding
     num_canonical_geos = num_canonical_geos + 1
     canonical_geos[num_canonical_geos] = geo
  end
  -- Left and right
  for i=1, 2 do
     geo = {}
     local padding = min_padding_step * 2
     geo.x = (screen_geo.width / 2) * (i - 1) + padding
     geo.y = padding + screen_geo.y
     geo.width = screen_geo.width / 2 - padding * 2
     geo.height = screen_geo.height - padding * 2
     num_canonical_geos = num_canonical_geos + 1
     canonical_geos[num_canonical_geos] = geo
  end
  -- Look for current geo among the canonical geos
  local orig_geo = aal.get_client_geometry(c)
  local new_geo_index = 1
  for i,geo in pairs(canonical_geos) do
     if geo_equals(geo, orig_geo) then
        if was_floating then
           new_geo_index = i + dir
        else
           -- If window was not floating and the floating position is
           -- already in a canonical position, it's preferable to stay
           -- in that position for now.  (Think about switching back
           -- and forth using Ctrl+D and Ctrl+P.  You wouldn't want
           -- each Ctrl+P to end up in different position).
           new_geo_index = i
        end
        if new_geo_index > num_canonical_geos then
           new_geo_index = 1
        elseif new_geo_index < 1 then
           new_geo_index = num_canonical_geos
        end
     end
  end
  aal.set_client_geometry(c, canonical_geos[new_geo_index])
end

function zk.raise_focus_client()
   if client.focus then
      if aal.is_panel(client.focus) then
         -- xfce4-panel will steal focus after switching tag. Try to
         -- restore to the previous focus.
         awful.client.focus.history.previous()
         -- If previous focus is still the panel, try to find a
         -- non-panel window
         local clients = client.get(mouse.screen)
         -- Try at most the number of client's times
         for k,c in pairs(clients) do
            if client.focus and aal.is_panel(client.focus) then
               awful.client.focus.byidx(1)
            else
               break
            end
         end
      else
         client.focus:raise()
      end
   end
end

function zk.notify(text, last_notification)
   if last_notification then
      aal.delete_notification(last_notification)
   end
   return aal.create_notification(text, "top_right", beautiful.font)
end

function zk.notify_monospace(text, last_notification)
   if last_notification then
      aal.delete_notification(last_notification)
   end
   return aal.create_notification(text, "top_right", beautiful.font_monospace)
end

function zk.post_starts()
   restore_tag_names()
   aal.run_shell_command(zk.config_home .. "bin/start-xfce4-panel.sh")
   aal.run_shell_command(zk.config_home .. "bin/prepare-wallpaper.sh")
   aal.run_shell_command(zk.config_home .. "bin/post-start-commands.sh")
end

-- Switch to the next floating client to the left (dir = -1) or right
-- (dir = 1) of the current client.
function zk.next_floating_client(dir)
   local current_c = aal.get_focus_client()
   local closest_c = nil
   for k,c in pairs(client.get(mouse.screen)) do
      if c:isvisible() and c.floating and c ~= current_c then
         if not closest_c then
            closest_c = c
         else
            closest_c = get_closer_client(current_c, dir, c, closest_c)
         end
      end
   end
   if closest_c then
      aal.focus_client(closest_c)
      zk.raise_focus_client()
   end
end



function zk.task_list_filter(c, screen)
   return tasklist.filter.currenttags(c, screen) and not c.minimized and not c.floating
end

return zk
