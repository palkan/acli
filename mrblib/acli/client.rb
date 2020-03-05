module Acli
  class Client
    class Error < StandardError; end
    class ClonnectionClosedError < Error; end

    attr_reader :identifier, :socket, :commands,
                :msg_limit, :channel_to_subscribe,
                :connected, :url

    alias connected? connected

    attr_accessor :received_count, :last_ping_at

    def initialize(url, socket, options = {})
      @url = url
      @connected = false
      @socket = socket
      @commands = Commands.new(self)
      @channel_to_subscribe = options["c"]
      @msg_limit = options["m"] ? options["m"].to_i : nil
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
      in message:
        received(message)
      end
    end

    def connected!
      @connected = true
      puts "Connected to Action Cable at #{@url}"
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
      close if msg_limit&.zero?
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
      close if msg_limit == received_count
    end
  end
end
