class IOLoop
  # List of streams that this IO loop will handle
  attr_reader :streams

  def initialize
    @streams = []
  end

  # Low-level API for adding a stream.
  def <<(stream)
    @streams << stream
    stream.on(:close) do
      @streams.delete(stream)
    end
  end

  # Some useful helpers:
  def io(io)
    stream = Stream.new(io)
    self << stream
    stream
  end

  def open(file, *args)
    io File.open(file, *args)
  end

  def connect(host, port)
    io TCPSocket.new(host, port)
  end

  def listen(host, port)
    server = Server.new(TCPServer.new(host, port))
    self << server
    server.on(:accept) do |stream|
      self << stream
    end
    server
  end

  # Start the loop by calling #tick over and over again.
  def start
    @running = true
    tick while @running
  end

  def tick
    @streams.each do |stream|
      stream.handle_read if stream.readable?
      stream.handle_write if stream.writable?
    end
  end
end
