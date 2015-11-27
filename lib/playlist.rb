class Playlist

  CACHE_DIR = "cache/"
  CACHE_SIZE = 5

  def initialize mpg123, plex_client
    @mpg123 = mpg123
    @plex_client = plex_client

    @playing = false
    @list = []
  end

  def add server, port, track
    @list.push [server, port, track]

    play 0 # unless @mpg123.playing
  end

  def play index
    server, port, track = @list[index]
    filename = cache server, port, track
    @mpg123.play filename
  end

  def cache server, port, track
    filename = CACHE_DIR + track.cache_filename

    if ! File.exists? filename

      # Clear down cache
      Dir[CACHE_DIR + "*.mp3"]
        .select{ |f| File.file? f }
        .sort_by{ |f| File.mtime f }
        .drop(CACHE_SIZE)
        .each{ |f| File.delete f }

      # Create new cached item
      File.open(filename, 'w') { |file| 
        file.write(@plex_client.fetch(server, port, track.file))
      }
    end

    filename
  end

end
