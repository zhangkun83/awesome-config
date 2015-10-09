mythememod = config_home .. "theme/theme-home.lua"

myawesomemenu = {
   { "cheat sheet", cheatsheet_command },
   { "edit config", terminal .. " --default-working-directory .config/awesome" },
   { "restart", awesome.restart },
   { "quit", {
       { "yes", awesome.quit },
       { "no", function() end } } },
   { "sleep", config_home .. "bin/sleepnlock.sh"}
}

mywiboxprops = { height = 24, border_width = "1" }

mykeybindings = awful.key({ modkey }, "\\", function () run_shell_command(config_home .. "bin/chrome-default-user.sh") end)

function myautostarts()
    start_if_absent("nm-applet", "nm-applet")
end
