require "nokogiri"
require "net/http"
require "uri"
require_relative "models"

# Plex Client library

class PlexClient

  PLEXTV_SERVER = "https://plex.tv"

  def login username, password
    uri = URI.parse(PLEXTV_SERVER + "/users/sign_in.xml")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth(username, password)
    add_headers(request, nil)

    response = http.request(request)
    
    xml = Nokogiri::XML(response.body)
    @token = xml.xpath("//user/authentication-token").first.content
  end

  def servers
    uri = URI.parse("https://plex.tv/pms/servers")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    add_headers(request, @token)

    response = http.request(request)

    Nokogiri::XML(response.body)
      .xpath("//MediaContainer/Server")
      .map { |xnode| Server.from_xml(xnode) }
  end

  def libraries server, port
    uri = URI.parse("https://#{server}:#{port}/library/sections")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    add_headers(request, @token)

    response = http.request(request)

    Nokogiri::XML(response.body)
      .xpath("//MediaContainer/Directory")
      .map { |xnode| Directory.from_xml(xnode) }
  end

  def library server, port, library, type = "albums"
    uri = URI.parse("https://#{server}:#{port}/library/sections/#{library}/#{type}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    add_headers(request, @token)

    response = http.request(request)

    Nokogiri::XML(response.body)
      .xpath("//MediaContainer/Directory")
      .map { |xnode| Directory.from_xml(xnode) }
  end

  def list server, port, key
    uri = URI.parse("https://#{server}:#{port}#{key}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    add_headers(request, @token)

    response = http.request(request)

    xdoc = Nokogiri::XML(response.body)

    dirs = xdoc
      .xpath("//MediaContainer/Directory")
      .map { |xnode| Directory.from_xml(xnode) }

    tracks = xdoc
      .xpath("//MediaContainer/Track")
      .map { |xnode| Track.from_xml(xnode) }

    [dirs, tracks]
  end

  def album server, port, key
    uri = URI.parse("https://#{server}:#{port}/#{key}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    add_headers(request, @token)

    response = http.request(request)

    Nokogiri::XML(response.body)
  end


  def fetch server, port, filename
    uri = URI.parse("https://82.69.102.189:25595/library/parts/2913/file.mp3")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    add_headers(request, @token)

    response = http.request(request)
    response.body
  end

  private

  # Fields required by Plex
  def add_headers request, token
    request.add_field("X-Plex-Client-Identifier", "c1cdae54-2451-484d-af6d-57ef573f35a1")
    request.add_field("X-Plex-Product", "Plex Music Player")
    request.add_field("X-Plex-Version", "0.1")

    request.add_field("X-Plex-Token", token) unless token.nil?
  end

end
