module Acli
  class Client
    class Error < StandardError; end
    class ClonnectionClosedError < Error; end

    MESSAGE_TYPES = {
      "welcome" => "print_welcome",
      "ping" => "track_ping",
      "confirm_subscription" => "subscribed"
    }

    attr_reader :identifier

    def initialize(url, protocol = "actioncable", headers = {})
      @uri = URI.parse(normalize_url(url))
      @ws = WebSocket::Client.new(:ws, @uri.host, @uri.port, @uri.path)
      @commands = Commands.new(self)

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

    def handle_command(command)
      @stdin_fd.events = 0

      if Commands.is?(command)
        command_msg = @commands.prepare_command(command)
        command_msg && @ws.send(command_msg)
      end
    ensure
      @stdin_fd.events = Poll::In
    end

    def handle_frame(frame)
      return unless frame

      if frame.opcode == :connection_close
        raise ClonnectionClosedError, "Closed with status: #{frame.status_code}"
      end

      handle_incoming frame.msg if frame.opcode == :text_frame
    end

    def close
      @ws.close
      exit 0
    end

    def handle_incoming(msg)
      data = JSON.parse(msg)
      if data.key?("type") && MESSAGE_TYPES.key?(data["type"])
        self.send(MESSAGE_TYPES[data["type"]], data)
      else
        received(data)
      end
    end

    def print_welcome(_)
      puts "Connected to Action Cable at #{@uri}"
    end

    def track_ping(_ping)
      @last_ping_at = Time.now
    end

    def subscribed(msg)
      @identifier = msg["identifier"]
      @channel = JSON.parse(@identifier)["channel"]
      puts "Subscribed to #{@channel} (#{@identifier})"
    end

    def received(msg)
      puts msg
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
