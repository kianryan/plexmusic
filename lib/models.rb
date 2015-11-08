
class Server
  attr_accessor :name, :address, :port

  def initialize(name, address, port)
    @name = name
    @address = address
    @port = port
  end

  def to_s
    name
  end

  def self.from_xml(xml)
    self.new(xml["name"], xml["host"], xml["port"])
  end
end

class Directory

  attr_accessor :key, :type, :title

  def initialize(key, type, title)
    @key = key
    @type = type
    @title = title
  end

  def to_s
    "#{title}:#{key}"
  end

  def self.from_xml(xml)
    self.new(xml["key"], xml["type"], xml["title"])
  end
end

class Library < Directory
end

class Track

  attr_accessor :key, :type, :title, :parentTitle, :grandParentTitle, :file

  def initialize(key, type, title, parentTitle, grandParentTitle, file)
    @key = key
    @type = type
    @title = title
    @parentTitle = parentTitle
    @grandParentTitle = grandParentTitle
    @file = file
  end

  def to_s
    title
  end

  def self.from_xml(xml)
    self.new(xml["key"], xml["type"], xml["title"], xml["parentTitle"],
            xml["grandParentTitle"], xml["file"])
  end
end
