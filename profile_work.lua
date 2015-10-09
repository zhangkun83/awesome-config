mythememod = config_home .. "theme/theme-work.lua"

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
    awful.key({ modkey }, "\\", function () run_shell_command(config_home .. "bin/chrome-default-user.sh") end),
    awful.key({ modkey, "Shift" }, "\\", function () run_shell_command(config_home .. "bin/chrome-personal.sh") end)
)

function myautostarts()
    -- load nvidia settings
    run_shell_command("nvidia-settings -l")
end
