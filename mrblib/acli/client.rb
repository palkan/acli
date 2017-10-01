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

    def initialize(url, headers = {}, options = {})
      url = normalize_url(url)
      @uri = URI.parse(url)
      @ws = WebSocket::Client.new(protocol(url), @uri.host, @uri.port, @uri.path, tls_config)
      @commands = Commands.new(self)
      @channel_to_subscribe = options["c"]
      @msg_limit = options["m"] ? options["m"].to_i : nil
      @received_count = 0

      poll = @ws.instance_variable_get(:@connection).instance_variable_get(:@poll)
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
      if frame.nil?
        raise ClonnectionClosedError, "Closed abnormally!"
      end

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
      subscribe if @channel_to_subscribe
    end

    def track_ping(_ping)
      @last_ping_at = Time.now
    end

    def subscribed(msg)
      @identifier = msg["identifier"]
      @channel = JSON.parse(@identifier)["channel"]
      puts "Subscribed to #{@channel} (#{@identifier})"
      close if @msg_limit && @msg_limit.zero?
    end

    def received(msg)
      puts msg
      track_incoming
    end

    def subscribe
      handle_command "\\s #{@channel_to_subscribe}"
    end

    def track_incoming
      @received_count += 1
      close if @msg_limit && (@msg_limit == @received_count)
    end

    # Downcase and prepend with protocol if missing
    def normalize_url(url)
      url = url.downcase
      # Replace ws protocol with http, 'cause URI cannot resolve port for non-HTTP
      url.sub!("ws", "http")
      url = "http://#{url}" unless url.start_with?("http")
      url
    end

    def protocol(url)
      url.start_with?("https") ? :wss : :ws
    end

    def tls_config
      Tls::Config.new(noverify: true)
    end
  end
end
