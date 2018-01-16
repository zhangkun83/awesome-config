mythememod = {
   font = "Liberation Sans 12",
   font_monospace = "Liberation Mono 12",
   menu_height = "28"
}

myawesomemenu = {
    { "cheat sheet", cheatsheet_command },
    { "edit config", terminal .. " --default-working-directory .config/awesome" },
    { "restart", awesome.restart },
    { "quit", {
        { "yes", aal.quit_awesome },
        { "no", function() end } } }
}

mywiboxprops = { height = 26, border_width = "0" }

mykeybindings = awful.util.table.join(
    awful.key({ modkey }, "\\", function () aal.run_shell_command(zk.config_home .. "bin/chrome-default-user.sh") end),
    awful.key({ modkey, "Shift" }, "\\", function () aal.run_shell_command(zk.config_home .. "bin/chrome-personal.sh") end)
)

function myautostarts()
    aal.run_shell_command("redshift -O 6100")
    -- Set mouse speed.  (Negative value sets it slower than default).
    aal.run_shell_command("xinput set-prop 'Logitech USB Optical Mouse' --type=float 'libinput Accel Speed' -0.2")
    -- something wrong with my workstation that I need to restart ibus-daemon
    -- to get it actually work.
    aal.run_shell_command(zk.config_home .. "bin/restart_ibus.sh")
end
