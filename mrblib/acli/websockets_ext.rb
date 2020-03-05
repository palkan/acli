module WebSocket
  class WsConnection
    def http_handshake
      key = WebSocket.create_key

      headers = [
        "Host: #{@host}:#{@port}",
        "Connection: Upgrade",
        "Upgrade: websocket",
        "Sec-WebSocket-Version: 13",
        "Sec-WebSocket-Key: #{key}"
      ]
      headers_str = headers.join("\r\n")

      @socket.write("GET #{@path} HTTP/1.1\r\n#{headers_str}\r\n\r\n")
      buf = @socket.recv(16384)
      phr = Phr.new
      while true
        case phr.parse_response(buf)
        when Fixnum
          break
        when :incomplete
          buf << @socket.recv(16384)
        when :parser_error
          raise Error, "HTTP Parser error"
        end
      end
      unless WebSocket.create_accept(key).securecmp(phr.headers.to_h.fetch('sec-websocket-accept'))
        raise Error, "Handshake failure"
      end
    end
  end
end
