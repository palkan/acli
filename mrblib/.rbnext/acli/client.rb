module Acli
  class Client
    class Error < StandardError
    end
    class ClonnectionClosedError < Error
    end
    attr_reader(:identifier, :socket, :commands, :msg_limit, :channel_to_subscribe, :connected, :url)
    alias :connected? :connected
    attr_accessor(:received_count, :last_ping_at)
    def initialize(url, socket, options = {})
      @url = url
      @connected = false
      @socket = socket
      @commands = Commands.new(self)
      @channel_to_subscribe = options["c"]
      @msg_limit = if options["m"]
        options["m"].to_i
      else
        nil
      end
      @received_count = 0
    end
    def handle_command(command)
      unless command
        return
      end
      unless Commands.is?(command)
        return
      end
      commands.prepare_command(command).then do |msg|
        unless msg
          next
        end
        socket.send(msg)
      end
    end
    def close
      socket.close
      exit(0)
    end
    def handle_incoming(msg)
      data = JSON.parse(msg).transform_keys!(&:to_sym)
      __m__ = data
      if (__m__.respond_to?(:deconstruct_keys) && ((((__m_hash__src__ = __m__.deconstruct_keys([:type, :identifier])) || true) && (((Hash === __m_hash__src__) || Kernel.raise(TypeError, "#deconstruct_keys must return Hash")) && (__m_hash__ = __m_hash__src__))) && (("confirm_subscription" === __m_hash__[:type]) && (__m_hash__.key?(:identifier) && ((identifier = __m_hash__[:identifier]) || true)))))
        subscribed!(identifier)
      else
        if (__m__.respond_to?(:deconstruct_keys) && ((((__m_hash__src__ = __m__.deconstruct_keys([:type])) || true) && (((Hash === __m_hash__src__) || Kernel.raise(TypeError, "#deconstruct_keys must return Hash")) && (__m_hash__ = __m_hash__src__))) && ("ping" === __m_hash__[:type])))
          track_ping!
        else
          if (__m__.respond_to?(:deconstruct_keys) && ((((__m_hash__src__ = __m__.deconstruct_keys([:type])) || true) && (((Hash === __m_hash__src__) || Kernel.raise(TypeError, "#deconstruct_keys must return Hash")) && (__m_hash__ = __m_hash__src__))) && ("welcome" === __m_hash__[:type])))
            connected!
          else
            if (__m__.respond_to?(:deconstruct_keys) && ((((__m_hash__src__ = __m__.deconstruct_keys([:message])) || true) && (((Hash === __m_hash__src__) || Kernel.raise(TypeError, "#deconstruct_keys must return Hash")) && (__m_hash__ = __m_hash__src__))) && (__m_hash__.key?(:message) && ((message = __m_hash__[:message]) || true))))
              received(message)
            else
              Kernel.raise(NoMatchingPatternError, __m__.inspect)
            end
          end
        end
      end
    end
    def connected!
      @connected = true
      puts("#{"Connected to Action Cable at "}#{@url}")
      if channel_to_subscribe
        subscribe
      end
    end
    def track_ping!
      self.last_ping_at=Time.now
    end
    def subscribed!(identifier)
      @identifier = identifier
      channel_name = begin
        JSON.parse(identifier)["channel"]
      rescue
        identifier
      end
      puts("#{"Subscribed to "}#{channel_name}")
      if msg_limit&.zero?
        close
      end
    end
    def received(msg)
      puts(msg.to_json)
      track_incoming
    end
    def subscribe
      handle_command("#{"\\s "}#{channel_to_subscribe}")
    end
    def track_incoming
      self.received_count += 1
      if (msg_limit == received_count)
        close
      end
    end
  end
end