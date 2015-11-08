#! /usr/local/bin/ruby

require_relative "lib/ui"
require_relative "lib/plex_client"

begin
  ui = UI.new
  plex = PlexClient.new

  username, password = ui.login

  plex.login username, password

  ui.init_list plex.servers

  # puts @plex.libraries server.address, server.port
  # puts @plex.library server.address, server.port, 1, "albums"
  # dirs, tracks = @plex.list server.address, server.port, "/library/metadata/3232/children"

  # puts tracks
ensure
  UI.finalize
end

