-- A modified version of max layout.  It tosses other tiling clients
-- off the screen, so that their shadows won't darken the shadow of
-- the focused client.

-- Grab environment we need
local pairs = pairs

local max = {}

local function fmax(p)
   local area = p.workarea

   local focus = client.focus
   if focus and not focus.floating then
      for _, c in pairs(p.clients) do
         local g = {}
         g.width = area.width
         g.height = area.height
         if client.focus == c then
            g.x = area.x
            g.y = area.y
         else
            g.x = area.x + area.width
            g.y = area.y + area.height
         end
         p.geometries[c] = g
      end
   end
end

max.name = "max"
function max.arrange(p)
    return fmax(p)
end

return max

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
