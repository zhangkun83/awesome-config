mythememod = zk.config_home .. "theme/theme-work.lua"

myawesomemenu = {
    { "cheat sheet", cheatsheet_command },
    { "edit config", terminal .. " --default-working-directory .config/awesome" },
    { "restart", awesome.restart },
    { "quit", {
        { "yes", awesome.quit },
        { "no", function() end } } }
}

mywiboxprops = { height = 26, border_width = "0" }

mykeybindings = awful.util.table.join(
    awful.key({ modkey }, "\\", function () zk.run_shell_command(zk.config_home .. "bin/chrome-default-user.sh") end),
    awful.key({ modkey, "Shift" }, "\\", function () zk.run_shell_command(zk.config_home .. "bin/chrome-personal.sh") end)
)

function myautostarts()
    -- load nvidia settings
    zk.run_shell_command("nvidia-settings -l")
    -- Set mouse speed
    zk.run_shell_command("xset m 1/5 10")
    -- something wrong with my workstation that I need to restart ibus-daemon
    -- to get it actually work.
    zk.run_shell_command(zk.config_home .. "bin/restart_ibus.sh")
end
