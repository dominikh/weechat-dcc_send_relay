def weechat_init
  Weechat.register("dcc_send_relay",
                   "Dominik Honnef",
                   "0.0.1",
                   "MIT",
                   "Relay DCC SEND requests to a different IRC client.",
                   "",
                   "")
  Weechat.hook_modifier "irc_in_privmsg", "dcc_send_cb", ""
  return Weechat::WEECHAT_RC_OK
end

def dcc_send_cb(data, signal, server, args)
  msg     = Weechat.info_get_hashtable("irc_message_parse", "message" => args)
  message = msg["arguments"].split(":", 2)

  if message[1] !~ /^\001DCC SEND .+\001$/
    return args
  end

  target_server = Weechat.config_get_plugin("relay_server")
  target_server = server if target_server.empty?
  server_buffer = Weechat.buffer_search("irc", "server." + target_server)
  target_nick   = Weechat.config_get_plugin("relay_nick")

  if target_nick.empty?
    Weechat.print("", "Cannot relay DCC SEND without a configured target nick.")
    return args
  end

  if server_buffer.empty?
    Weechat.print("", "Couldn't find a server buffer for '#{target_server}'.")
    return args
  end

  Weechat.command(server_buffer, "/MSG %s %s" % [target_nick, message[1]])
  return ""
end
