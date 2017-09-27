mythememod = {
   font = "Liberation Sans 12",
   font_monospace = "Liberation Mono 12",
   menu_height = "28"
}

myawesomemenu = {
    { "cheat sheet", cheatsheet_command },
    { "lock screen", function() aal.run_shell_command(zk.config_home .. "bin/xlock.sh") end },
    { "sleep", zk.config_home .. "bin/sleepnlock.sh" },
    { "restart", awesome.restart },
    { "quit", {
        { "yes", awesome.quit },
        { "no", function() end } } }
}

mywiboxprops = { height = 26, border_width = "0" }

mycustomwidgets = { }

for _,v in ipairs(mycustomwidgets) do
   v:set_font(mythememod.font)
end

mykeybindings = awful.util.table.join(
    awful.key({ modkey }, "\\", function () aal.run_shell_command(zk.config_home .. "bin/chrome-default-user.sh") end),
    awful.key({ modkey, "Shift" }, "\\", function () aal.run_shell_command(zk.config_home .. "bin/chrome-personal.sh") end)
)

function myautostarts()
    -- Disable touchpad tapping
    aal.run_shell_command("synclient TapButton1=0 TapButton2=0")
    -- Shift the color a bit towards red to reduce eye strain
    aal.run_shell_command("redshift -O 6100")
    -- Make fonts slightly larger
    aal.run_shell_command("xrdb -merge <<< \"Xft.dpi: 105\"")
    aal.run_shell_command("nm-applet")
    aal.run_shell_command("xfce4-power-manager")
    -- something wrong with my workstation that I need to restart ibus-daemon
    -- to get it actually work.
    aal.run_shell_command(zk.config_home .. "bin/restart_ibus.sh")
end
