require 'socket'

class ChatServer
  def initialize
    @clients = []
    @client_id = 0
  end

  def <<(server)
    server.on(:accept) do |stream|
      add_client(stream)
    end
  end

  def add_client(stream)
    id = (@client_id += 1)
    send("User ##{id} joined\n")

    stream.on(:data) do |chunk|
      send("User ##{id} said: #{chunk}")
    end

    stream.on(:close) do
      @clients.delete(stream)
      send("User ##{id} left")
    end

    @clients << stream
  end

  def send(msg)
    @clients.each do |stream|
      stream << msg
    end
  end
end


io = IOLoop.new
server = ChatServer.new

server << io.listen('0.0.0.0', 1234)

io.start
