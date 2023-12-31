module Acli
  class Client
    attr_reader :identifier, :socket, :commands,
                :quit_after, :quit_after_messages, :channel_to_subscribe,
                :connected, :url, :coder, :logger, :pong

    alias connected? connected

    attr_accessor :received_count, :last_ping_at, :last_seen_stream, :last_seen_epoch

    def initialize(url, socket, channel: nil, quit_after: nil, coder: Coders::JSON, pong: false, logger: NoopLogger.new)
      @logger = logger
      @url = url
      @connected = false
      @socket = socket
      @commands = Commands.new(self, logger: logger)
      @channel_to_subscribe = channel
      @coder = coder
      @pong = pong

      parse_quit_after!(quit_after) if quit_after

      @received_count = 0

      logger.log "Client: url=#{url}, channel=#{channel_to_subscribe}, quit_after: #{quit_after}"
    end

    def frame_format
      coder.frame_format
    end

    def handle_command(command)
      return unless command
      return unless Commands.is?(command)

      commands.prepare_command(command).then do |msg|
        next unless msg
        socket.send(msg, frame_format)
      end
    end

    def close
      socket.close
      exit 0
    end

    def handle_incoming(msg)
      logger.log "Incoming: #{msg}"

      data = coder.decode(msg).transform_keys!(&:to_sym)

      case data[:type]
      when "confirm_subscription"
        subscribed! data[:identifier]
      when "reject_subscription"
        puts "Subscription rejected"
      when "confirm_history"
        # no-op
      when "reject_history"
        puts "Failed to retrieve history"
      when "ping"
        track_ping!
      when "welcome"
        connected!(data)
      when "disconnect"
        puts "Disconnected by server: " \
             "#{data.fetch(:reason, "unknown reason")} " \
             "(reconnect: #{data.fetch(:reconnect, "<none>")})"
        close
      else
        if data[:message] && data[:identifier]
          received(data[:message], data)
        end
      end
    end

    def connected!(opts)
      @connected = true
      puts "Connected to Action Cable at #{@url}"
      puts "Session ID: #{opts[:sid]}#{opts[:restored] ? ' (restored)' : ''}" if opts[:sid]
      quit! if quit_after == "connect"
      subscribe if channel_to_subscribe
    end

    def track_ping!
      self.last_ping_at = Time.now

      if pong
        socket.send coder.encode({ "command" => "pong" }), frame_format
      end
    end

    def subscribed!(identifier)
      @identifier = identifier
      channel_name =
        begin
          JSON.parse(identifier)["channel"]
        rescue
          identifier
        end
      puts "Subscribed to #{channel_name}"
      quit! if quit_after == "subscribed"
    end

    def received(msg, meta)
      puts msg.to_json + format_meta(meta)

      if meta[:stream_id]
        self.last_seen_stream = meta[:stream_id]
        self.last_seen_epoch = meta[:epoch]
      end

      track_incoming
    end

    def format_meta(meta)
      return "" if meta.empty?

      " # stream_id=#{meta[:stream_id]} epoch=#{meta[:epoch]} offset=#{meta[:offset]}"
    end

    def subscribe
      handle_command "\\s #{channel_to_subscribe}"
    end

    def track_incoming
      self.received_count += 1
      quit! if quit_after == "message" && quit_after_messages == received_count
    end

    def quit!
      puts "Quit."
      close
    end

    def parse_quit_after!(value)
      @quit_after =
        case value
        when "connect", "subscribed"
          value
        when /\d+/
          @quit_after_messages = value.to_i
          "message"
        end
    end
  end
end
