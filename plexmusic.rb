#! /usr/local/bin/ruby

require_relative "lib/ui"
require_relative "lib/plex_client"

begin
  ui = UI.new
  plex = PlexClient.new

  username, password = ui.login
  plex.login username, password

  list = plex.servers
  server = nil

  while ! (index = ui.init_list list).nil?
    selected = list[index]

    if selected.is_a?(Server)
      server = selected
      list = plex.libraries(server.address, server.port)
    elsif selected.is_a?(Library)
      list = plex.library(server.address, server.port, selected.key)
    elsif selected.is_a?(Directory)
      list = plex.list(server.address, server.port, selected.key)
    elsif selected.is_a?(Track)
      # Play track
    end
  end
ensure
  UI.finalize
end

