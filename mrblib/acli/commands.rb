# require: "utils"

module Acli
  class Commands
    include Utils

    COMMANDS = {
      "s" => "subscribe",
      "s+" => "isubscribe",
      "p" => "perform",
      "p+" => "iperform",
      "?" => "print_help",
      "q" => "quit"
    }

    def self.is?(str)
      str =~ /^\\[\w\?]+\+?/
    end

    def initialize(client)
      @client = client
    end

    def prepare_command(str)
      m = /^\\([\w\?]+\+?)(?:\s+(\w+))?(.*)/.match(str)
      cmd, arg, options = m[1], m[2], m[3]
      return puts "Unknown command: #{cmd}" unless COMMANDS.key?(cmd)
      args = []
      args << arg if arg && !arg.strip.empty?
      args << parse_kv(options) if options && !options.strip.empty?
      self.send(COMMANDS.fetch(cmd), *args)
    end

    def print_help
      puts <<-USAGE
Commands:

  \\s channel [params]      # Subscribe to channel (you can provide params
                             using key-value string, e.g. "id:2 name:jack")
  \\s+ [channel] [params]   # Interactive subscribe

  \\p action [params]       # Perform action
  \\p+ [action] [params]    # Interactive version of perform action

  \\q                       # Exit
  \\?                       # Print this help
      USAGE
    end

    def subscribe(channel, params = {})
      params["channel"] = channel
      { "command" => "subscribe", "identifier" => params.to_json }.to_json
    end

    def isubscribe(channel = nil, params = {})
      channel ||= prompt("Enter channel ID: ")
      params.merge!(request_message)
      subscribe(channel, params)
    end

    def perform(action, params = {})
      data = params.merge(action: action)
      { "command" => "message", "identifier" => @client.identifier, "data" => data.to_json }.to_json
    end

    def iperform(action = nil, params = {})
      action ||= prompt("Enter action: ")
      params.merge!(request_message)
      perform(action, params)
    end

    def quit
      puts "Good-bye!.."
      @client.close
      nil
    end

    def request_message
      msg = {}
      loop do
        key = prompt("Enter key (or press ENTER to finish): ")
        break msg if key.empty?
        msg[key] = serialize(prompt("Enter value: "))
      end
    end

    def parse_kv(str)
      str.scan(/(\w+)\s*:\s*([^\s\:]*)/).each_with_object({}) do |kv, acc|
        k, v = kv[0], kv[1]
        acc[k] = serialize(v)
      end
    end
  end
end
