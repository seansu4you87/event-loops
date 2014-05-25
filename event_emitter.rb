module EventEmitter
  def _callbacks
    @_callbacks ||= Hash.new { |h, k| h[k] = [] }
  end

  def on(type, &blk)
    _callbacks[type] << blk
    self
  end

  def emit(type, *args)
    _callbacks[type].each do |blk|
      blk.call(*args)
    end
  end
end

class HTTPServer
  include EventEmitter
end

server = HTTPServer.new
server.on(:request) do |req, res|
  res.respond(200, 'Content-Type' => 'text/html')
  res << "Hello world!"
  res.close
end

# When a new request comes in, the server will run:
#   server.emit(:request, req, res)
