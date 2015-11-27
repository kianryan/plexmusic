
class MpgPlayer

  def initialize
    @pid = []
  end

  def playing
    #! @pid.empty?
    return false
  end

  def play filename
    Thread.new do
      @pid.each { |p| Process.kill(9, p) }
      local_pid = Process.spawn("mpg123 -q " + filename)
      @pid.push(local_pid)
      Process.wait local_pid
      @pid.delete(local_pid)
    end
  end
end
