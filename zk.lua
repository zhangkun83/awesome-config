local zk = {}

zk.config_home = os.getenv("HOME") .. "/.config/awesome/"

function zk.raise_focus_client()
  if client.focus then client.focus:raise() end
end

function zk.run_shell_command(command)
    awful.util.spawn_with_shell(command)
end

function zk.notify(text, last_notification)
   if last_notification then
      naughty.destroy(last_notification)
   end
   return naughty.notify({ text = text,
                           position = "top_right",
                           timeout = 10})
end

function zk.notify_monospace(text, last_notification)
   if last_notification then
      naughty.destroy(last_notification)
   end
   return naughty.notify({ text = text,
                           font = "Liberation Mono 12",
                           position = "top_right",
                           timeout = 10})
end

return zk
