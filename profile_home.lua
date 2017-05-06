mythememod = zk.config_home .. "theme/theme-home.lua"

myawesomemenu = {
   { "cheat sheet", cheatsheet_command },
   { "edit config", terminal .. " --default-working-directory .config/awesome" },
   { "restart", awesome.restart },
   { "quit", {
       { "yes", awesome.quit },
       { "no", function() end } }
   },
   { "sleep", zk.config_home .. "bin/sleepnlock.sh" },
   { "power off", {
       { "yes", zk.config_home .. "bin/poweroff.sh" },
       { "no", function() end } }
   }
}

mywiboxprops = { height = 24, border_width = "0" }

mykeybindings = awful.key({ modkey }, "\\", function () zk.run_shell_command(zk.config_home .. "bin/chrome-default-user.sh") end)

function myautostarts()
    -- Set mouse speed
    zk.run_shell_command("xset m 1/5 10")
end
