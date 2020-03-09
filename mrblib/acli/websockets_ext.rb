module WebSocket
  class WsConnection
    attr_accessor :custom_headers

    def http_handshake
      key = WebSocket.create_key

      headers = [
        "Host: #{@host}:#{@port}",
        "Connection: Upgrade",
        "Upgrade: websocket",
        "Sec-WebSocket-Version: 13",
        "Sec-WebSocket-Key: #{key}"
      ]

      headers += custom_headers if custom_headers

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

      response_headers = phr.headers.to_h

      unless response_headers.key?('sec-websocket-accept')
        raise Error, "WebSocket upgrade failed"
      end

      unless WebSocket.create_accept(key).securecmp(response_headers.fetch('sec-websocket-accept'))
        raise Error, "Handshake failure"
      end
    end
  end
end
