
class MpgPlayer
  
# def play_file token
#   uri = URI.parse("https://82.69.102.189:25595/library/parts/2913/file.mp3")
# 
#   http = Net::HTTP.new(uri.host, uri.port)
#   http.use_ssl = true
#   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
# 
#   request = Net::HTTP::Get.new(uri.request_uri)
#   add_headers(request, token)
# 
#   response = http.request(request)
#   File.open("temp.mp3", 'w') { |file| file.write(response.body) }
# 
#   pid = Process.spawn("mpg123 -q temp.mp3")
#   Process.waitpid(pid)
# end

  def play filename
    

  end
end