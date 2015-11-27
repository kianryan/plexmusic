#! /usr/local/bin/ruby

require_relative "lib/ui"
require_relative "lib/plex_client"
require_relative "lib/mpg123"
require_relative "lib/playlist"

begin
  ui = UI.new
  plex = PlexClient.new
  player = MpgPlayer.new
  playlist = Playlist.new player, plex

  username, password = ui.login
  plex.login username, password

  list = plex.servers
  server = nil

  previous = []
  selected = nil

  while ! (index = ui.init_list list).nil?
    if index == -1
      selected = previous.pop
    else
      previous.push(selected)
      selected = list[index]
    end

    if selected.nil?
      list = plex.servers
    elsif selected.is_a?(Server)
      server = selected
      list = plex.libraries(server.address, server.port)
    elsif selected.is_a?(Library)
      list = plex.library(server.address, server.port, selected.key)
    elsif selected.is_a?(Directory)
      list = plex.list(server.address, server.port, selected.key)
    elsif selected.is_a?(Track)
      playlist.add server.address, server.port, selected
    end
  end
ensure
  UI.finalize
end

