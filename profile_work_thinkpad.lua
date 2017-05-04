mythememod = config_home .. "theme/theme-work.lua"

myawesomemenu = {
    { "cheat sheet", cheatsheet_command },
    { "edit config", terminal .. " --default-working-directory .config/awesome" },
    { "lock screen", function() run_shell_command(config_home .. "bin/xlock.sh") end },
    { "sleep", config_home .. "bin/sleepnlock.sh" },
    { "restart", awesome.restart },
    { "quit", {
        { "yes", awesome.quit },
        { "no", function() end } } }
}

mywiboxprops = { height = 26, border_width = "0" }

mybatterybox = wibox.widget.textbox("?battery?")
mybatterybox:set_font("Liberation Mono 12")
mybatterybox:buttons(awful.button({ }, 1, function() awful.util.spawn(config_home .. "bin/show-system-status.sh") end))

mynetworkbox = wibox.widget.textbox("?network?")
mynetworkbox:set_font("Liberation Mono 12")

mycustomwidgets = { mynetworkbox, mybatterybox }

mykeybindings = awful.util.table.join(
    awful.key({ modkey }, "\\", function () run_shell_command(config_home .. "bin/chrome-default-user.sh") end),
    awful.key({ modkey, "Shift" }, "\\", function () run_shell_command(config_home .. "bin/chrome-personal.sh") end),
    awful.key({ }, "XF86Tools", function() awful.util.spawn(config_home .. "bin/show-system-status.sh") end)
)

function myautostarts()
    -- Disable touchpad tapping
    run_shell_command("synclient TapButton1=0")
    run_shell_command("synclient TapButton2=0")
    -- Shift the color a bit towards red to reduce eye strain
    run_shell_command("redshift -O 6100")
    -- Make fonts slightly larger
    run_shell_command("xrdb -merge <<< \"Xft.dpi: 105\"")
    -- something wrong with my workstation that I need to restart ibus-daemon
    -- to get it actually work.
    run_shell_command(config_home .. "bin/restart_ibus.sh")
    start_if_absent(config_home .. "bin/laptopboxes-updater.sh", "laptopboxes-updater.sh")
end
