module Acli
  class Commands
    COMMANDS = {
      "s" => "subscribe",
      "s+" => "isubscribe",
      "p" => "perform",
      "p+" => "iperform",
      "h" => "history",
      "?" => "print_help",
      "q" => "quit"
    }

    def self.is?(str)
      str =~ /^\\[\w\?]+\+?/
    end

    attr_reader :client, :logger

    def initialize(client, logger: NoopLogger.new)
      @logger = logger
      @client = client
    end

    def coder
      client.coder
    end

    def prepare_command(str)
      logger.log "Preparing command: #{str}"

      m = /^\\([\w\?]+\+?)(?:\s+((?:\w|\:\:)+(?:$|[^\:]\s)))?(.*)/.match(str)
      cmd, arg, options = m[1], m[2], m[3]
      return puts "Unknown command: #{cmd}" unless COMMANDS.key?(cmd)
      args = []
      args << arg.strip if arg && !arg.strip.empty?
      args << parse_kv(options) if options && !options.strip.empty?

      logger.log "Parsed command: #{cmd}(#{args})"
      self.send(COMMANDS.fetch(cmd), *args)
    rescue ArgumentError => e
      puts "Command failed: #{e.message}"
      nil
    end

    def print_help
      puts <<-USAGE
Commands:

  \\s channel [params]      # Subscribe to channel (you can provide params
                             using key-value string, e.g. "id:2 name:jack")
  \\s+ [channel] [params]   # Interactive subscribe

  \\p action [params]       # Perform action
  \\p+ [action] [params]    # Interactive version of perform action

  \\h since                 # Request message history since the specified time (UTC timestamp or string)

  \\q                       # Exit
  \\?                       # Print this help
      USAGE
    end

    def subscribe(channel, params = {})
      params["channel"] = channel
      coder.encode({ "command" => "subscribe", "identifier" => params.to_json })
    end

    def isubscribe(channel = nil, params = {})
      channel ||= Utils.prompt("Enter channel ID: ")
      params.merge!(request_message)
      subscribe(channel, params)
    end

    def perform(action, params = {})
      data = params.merge(action: action)
      coder.encode({ "command" => "message", "identifier" => @client.identifier, "data" => data.to_json })
    end

    def iperform(action = nil, params = {})
      action ||= Utils.prompt("Enter action: ")
      params.merge!(request_message)
      perform(action, params)
    end

    def history(params = {})
      raise ArgumentError, 'History command has a form: \\h since:<interval or timestamp>' unless params.is_a?(Hash)

      since = params&.fetch("since") { raise ArgumentError, "Since argument is required" }
      ts = nil

      begin
        ts = Integer(since)
      rescue ArgumentError
        ts = parse_relative_time(since)
      end

      coder.encode({ "command" => "history", "identifier" => @client.identifier, "history" => { "since" => ts } })
    end

    def quit
      puts "Good-bye!.."
      client.close
      nil
    end

    def request_message
      msg = {}
      loop do
        key = Utils.prompt("Enter key (or press ENTER to finish): ")
        break msg if key.empty?
        msg[key] = Utils.serialize(Utils.prompt("Enter value: "))
      end
    end

    def parse_kv(str)
      str.scan(/(\w+)\s*:\s*([^\s\:]*)/).each.with_object({}) do |kv, acc|
        k, v = kv[0], kv[1]
        acc[k] = Utils.serialize(v)
      end
    end

    def parse_relative_time(str)
      ts = Time.now.to_i

      val, precision = str[0..-2], str[-1..-1]

      val = Integer(val)

      case precision
      when "s"
        ts -= val
      when "m"
        ts -= (val * 60)
      when "h"
        ts -= (val * 60 * 60)
      else
        raise ArgumentError, "Unknown relative time: #{str}"
      end
    end
  end
end
