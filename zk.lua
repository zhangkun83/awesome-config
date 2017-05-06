aal = require("aal")

local zk = {}

zk.config_home = os.getenv("HOME") .. "/.config/awesome/"

local saved_tags_file = zk.config_home .. "runtime/saved_tags"

-- Run whenver the floating status of a window changes
local function on_floating_changed(c)
   aal.set_client_ontop(c, aal.is_client_floating(c))
   zk.raise_focus_client()
end

local function is_floating(c)
  return aal.is_in_floating_layout(c) or aal.is_client_floating(c)
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

local function create_title_bar(c)
   if aal.should_have_title_bar(c) then
      aal.create_title_bar(c)
      -- At least, make space for the window title, and do not extend over
      -- the borders of the screen
      place_window_sanely(c)
   end
end

local function restore_tag_names()
  local f = assert(io.open(saved_tags_file, "r"))
  local savedTags = tags[mouse.screen]
  for i = 1, table.getn(savedTags) do
    savedTags[i].name = f:read()
  end
  f:close()
end

-- Save tag names so that they survive after restart
local function save_tag_names()
  local f = assert(io.open(saved_tags_file, "w"))
  local savedTags = tags[mouse.screen]
  for i = 1, table.getn(savedTags) do
    f:write(savedTags[i].name)
    f:write("\n")
  end
  f:close()
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

  create_title_bar(c)
  on_floating_changed(c)
end

function zk.rename_tag()
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
end

function zk.set_floating_for_all_clients(value)
    local clients = client.get(mouse.screen)
    for k,c in pairs(clients) do
        if (c:isvisible()) then
           aal.set_client_floating(c, value)
        end
    end
end

function zk.minimize_all_floating_clients()
   local clients = client.get(mouse.screen)
   for k,c in pairs(clients) do
      if (aal.is_client_floating(c)) then
         c.minimized = true
      end
   end
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
  -- Only floating windows can be moved
  if not is_floating(c) then
    return
  end
  local geo = aal.get_client_geometry(c)
  local screen_geo = aal.get_workarea(c)
  geo.x = math.min(math.max(0, geo.x + dx), screen_geo.width - 50)
  geo.y = math.min(math.max(0, geo.y + dy), screen_geo.height - 50)
  geo.width = math.min(math.max(100, geo.width + dw), screen_geo.width)
  geo.height = math.min(math.max(100, geo.height + dh), screen_geo.height)
  aal.set_client_geometry(c, geo)
end

function zk.float_window_canonically(c, dir)
  if not is_floating(c) then
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
        new_geo_index = i + dir
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
  if client.focus then client.focus:raise() end
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
   aal.run_shell_command(zk.config_home .. "bin/prepare-wallpaper.sh")
   aal.run_shell_command(zk.config_home .. "bin/ibus-cycle-engine.sh 0")
   aal.run_shell_command(zk.config_home .. "bin/post-start-commands.sh")
end

return zk
