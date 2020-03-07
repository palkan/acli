module Acli
  class Client
    attr_reader :identifier, :socket, :commands,
                :quit_after, :quit_after_messages, :channel_to_subscribe,
                :connected, :url

    alias connected? connected

    attr_accessor :received_count, :last_ping_at

    def initialize(url, socket, channel: nil, quit_after: nil)
      @url = url
      @connected = false
      @socket = socket
      @commands = Commands.new(self)
      @channel_to_subscribe = channel

      parse_quit_after!(quit_after) if quit_after

      @received_count = 0
    end

    def handle_command(command)
      return unless command
      return unless Commands.is?(command)

      commands.prepare_command(command).then do |msg|
        next unless msg
        socket.send(msg)
      end
    end

    def close
      socket.close
      exit 0
    end

    def handle_incoming(msg)
      data = JSON.parse(msg).transform_keys!(&:to_sym)
      case data
      in type: "confirm_subscription", identifier:
        subscribed! identifier
      in type: "ping"
        track_ping!
      in type: "welcome"
        connected!
      in type: "disconnect", **opts
        puts "Disconnected by server: " \
             "#{opts.fetch(:reason, "unknown reason")} " \
             "(reconnect: #{opts.fetch(:reconnect, "<none>")})"
        close
      in message:
        received(message)
      end
    end

    def connected!
      @connected = true
      puts "Connected to Action Cable at #{@url}"
      quit! if quit_after == "connect"
      subscribe if channel_to_subscribe
    end

    def track_ping!
      self.last_ping_at = Time.now
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

    def received(msg)
      puts msg.to_json
      track_incoming
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
          in "connect" | "subscribed"
            value
          in /\d+/
            @quit_after_messages = value.to_i
            "message"
        end
    end
  end
end
