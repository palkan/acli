module Acli
  class Client
    def initialize(url, protocol = "actioncable", headers = {})
      @uri = URI.parse(normalize_url(url))
      @ws = WebSocket::Client.new(:ws, @uri.host, @uri.port, @uri.path)
      poll = @ws.poll
      @stdin_fd = poll.add(STDIN_FILENO, Poll::In)

      while ready_fds = poll.wait
        ready_fds.each do |ready_fd|
          if ready_fd == @stdin_fd
            command = STDIN.gets.chomp
            handle_command(command) if command.length > 0
          else
            handle_frame @ws.recv
          end
        end
      end
      @ws.close
    end

    private

    def handle_command(command)
      @stdin_fd.events = 0
      @ws.send(
        "{\"command\":\"subscribe\",\"identifier\":\"{\\\"channel\\\":\\\"chat\\\",\\\"id\\\":2}\"}"
      ) if command == "/sub"
    ensure
      @stdin_fd.events = Poll::In
    end

    def handle_frame(frame)
      puts frame.msg if frame && frame.opcode == :text_frame
    end

    # Downcase and prepend with protocol if missing
    def normalize_url(url)
      url = url.downcase
      # Replace ws protocol with http, 'cause URI cannot resolve port for non-HTTP
      url.sub!("ws", "http")
      url = "http://#{url}" unless url.start_with?("http")
      url
    end
  end
end
