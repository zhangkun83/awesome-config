-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

-- {{{ Main
theme = {}
local config_dir = os.getenv("HOME") .. "/.config/awesome/"
local theme_dir = config_dir .. "/theme/"
-- }}}

-- {{{ Styles
theme.font      = "sans 12"

-- {{{ Colors
theme.bg_focus                                  = '#0099EE'
theme.bg_normal                                 = '#333333'
theme.bg_urgent                                 = '#FCCBCC'
theme.bg_minimize                               = '#333333'
theme.fg_normal                                 = '#CCCCCC'
theme.fg_focus                                  = '#FFFFFF'
theme.fg_urgent                                 = '#000000'
theme.fg_minimize                               = '#666666'
theme.bg_widget                                 = '#FFFFFF'
theme.fg_widget                                 = '#000000'
theme.fg_center_widget                          = '#000000'
theme.fg_end_widget                             = '#000000'
theme.tooltip_bg_color                          = '#C1BCB7'
theme.tooltip_fg_color                          = '#000000'
-- }}}

-- {{{ Borders
theme.border_width  = "2"
theme.border_normal                             = '#DCDCDC'
theme.border_focus                              = '#0099EE'
theme.border_marked                             = '#5278AE'
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#0099EE"
theme.titlebar_fg_focus  = "#FFFFFF"
theme.titlebar_bg_normal = "#DCDCDC"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}
theme.taglist_bg_focus = "#5F5F5F"

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = "28"
theme.menu_width  = "200"
theme.menu_border_color = "#434750"
theme.menu_border_width = "1"
theme.menu_bg_focus = "#5F5F5F"
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = theme_dir .. "taglist/squarefz.png"
theme.taglist_squares_unsel = theme_dir .. "taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = theme_dir .. "awesome-icon.png"
theme.menu_submenu_icon      = theme_dir .. "submenu.png"
theme.tasklist_floating_icon = theme_dir .. "titlebar/floating_focus_active.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = theme_dir .. "layouts/tile.png"
theme.layout_tileleft   = theme_dir .. "layouts/tileleft.png"
theme.layout_tilebottom = theme_dir .. "layouts/tilebottom.png"
theme.layout_tiletop    = theme_dir .. "layouts/tiletop.png"
theme.layout_fairv      = theme_dir .. "layouts/fairv.png"
theme.layout_fairh      = theme_dir .. "layouts/fairh.png"
theme.layout_spiral     = theme_dir .. "layouts/spiral.png"
theme.layout_dwindle    = theme_dir .. "layouts/dwindle.png"
theme.layout_max        = theme_dir .. "layouts/max.png"
theme.layout_fullscreen = theme_dir .. "layouts/fullscreen.png"
theme.layout_magnifier  = theme_dir .. "layouts/magnifier.png"
theme.layout_floating   = theme_dir .. "layouts/floating.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = theme_dir .. "titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme_dir .. "titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = theme_dir .. "titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = theme_dir .. "titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = theme_dir .. "titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme_dir .. "titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = theme_dir .. "titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = theme_dir .. "titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = theme_dir .. "titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme_dir .. "titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = theme_dir .. "titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = theme_dir .. "titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = theme_dir .. "titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme_dir .. "titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = theme_dir .. "titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = theme_dir .. "titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme_dir .. "titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme_dir .. "titlebar/maximized_normal_inactive.png"

theme.titlebar_minimize_button_focus_inactive  = theme_dir .. "titlebar/minimize_focus.png"
theme.titlebar_minimize_button_normal_inactive = theme_dir .. "titlebar/minimize_normal.png"
-- }}}
-- }}}
