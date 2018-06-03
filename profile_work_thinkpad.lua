local awful = require("awful")

mythememod = {
   font = "Liberation Sans 12",
   font_monospace = "Liberation Mono 12",
   menu_height = "24",
   useless_gap = "5"
}

myawesomemenu = {
    { "lock screen", function() aal.run_shell_command(zk.config_home .. "bin/lock.sh") end },
    { "sleep", zk.config_home .. "bin/sleepnlock.sh" },
    { "restart", awesome.restart },
    { "quit", {
        { "yes", aal.quit_awesome },
        { "no", function() end } } }
}

mywiboxprops = { height = 24 }

mycustomwidgets = { }

for _,v in ipairs(mycustomwidgets) do
   v:set_font(mythememod.font)
end

mykeybindings = awful.util.table.join(
    awful.key({ modkey }, "\\", function () aal.run_shell_command(zk.config_home .. "bin/chrome-default-user.sh") end,
              {description = "Chrome (work profile)", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "\\", function () aal.run_shell_command(zk.config_home .. "bin/chrome-personal.sh") end,
              {description = "Chrome (personal profile)", group = "launcher"})
)

function myautostarts()
    -- Use "xinput list-props 'SynPS/2 Synaptics TouchPad'" to view all properties
    -- Do not disable touchpad while typing
    aal.run_shell_command("xinput set-prop 'SynPS/2 Synaptics TouchPad' --type=int 297 0")
    -- Enable both vertical and horizontal scrolling
    aal.run_shell_command("xinput set-prop 'SynPS/2 Synaptics TouchPad' --type=int 283 1 1")

    aal.run_shell_command("xfce4-power-manager")
    -- Shift the color a bit towards red to reduce eye strain
    aal.run_shell_command("redshift -O 6100")
    -- Make fonts slightly larger
    aal.run_shell_command("xrdb -merge <<< \"Xft.dpi: 105\"")
    -- something wrong with my workstation that I need to restart ibus-daemon
    -- to get it actually work.
    aal.run_shell_command(zk.config_home .. "bin/restart_ibus.sh")
end
