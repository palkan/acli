module Acli
  class Socket
    class Error < StandardError; end
    class ClonnectionClosedError < Error; end

    attr_reader :ws, :tls
    alias tls? tls

    def initialize(uri, headers = nil)
      @tls = uri.scheme == :https

      connection_class = tls? ? WebSocket::WssConnection : WebSocket::WsConnection

      fullpath = "#{uri.path}#{uri.query ? "?#{uri.query}" : ""}"
      @ws = connection_class.new(uri.host, uri.port, fullpath, tls_config)
      ws.custom_headers = headers

      setup_ws
    end

    def poll_socket
      tls? ? ws.instance_variable_get(:@tcp_socket) : ws.instance_variable_get(:@socket)
    end

    def setup_poller(poll)
      ws.instance_variable_set(:@poll, poll)
      poll.add(poll_socket.fileno).tap do |pi|
        ws.instance_variable_set(:@socket_pi, pi)
      end
    end

    def receive_frame(timeout = -1)
      handle_frame(ws.recv(timeout))
    end

    def send(msg, opcode = nil, timeout = -1)
      ws.send(msg, opcode, timeout)
    end

    def handle_frame(frame)
      if frame.nil?
        return
        raise ClonnectionClosedError, "Closed abnormally!"
      end

      if frame.opcode == :connection_close
        raise ClonnectionClosedError, "Closed with status: #{frame.status_code}"
      end

      frame.msg if frame.opcode == :text_frame
    end

    def close(status_code = :normal_closure, reason = nil, timeout = -1)
      ws.close(status_code, reason, timeout)
    end

    private

    # Based on WebSocket::WsConnection#setup
    def setup_ws
      ws.http_handshake
      ws.make_nonblock
      ws.setup_ws
    rescue => e
      @ws.instance_variable_get(:@socket).close
      raise e
    end

    def tls_config
      Tls::Config.new(noverify: true)
    end
  end
end
