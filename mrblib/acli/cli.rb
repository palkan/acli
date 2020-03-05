module Acli
  DEFAULT_CABLE_PATH = "/cable"

  class Cli
    def initialize(argv)
      @options = parse_options(argv)
    end

    def run
      print_version if @options["v"]
      print_help if @options["h"]
      ask_for_url unless @options["u"]

      uri =  URI.parse(Utils.normalize_url(@options["u"]))
      uri.instance_variable_set(:@path, DEFAULT_CABLE_PATH) if uri.path.nil? || uri.path.empty?

      poller = Poller.new
      socket = Socket.new(uri)
      client = Client.new(Utils.uri_to_ws_s(uri), socket, @options)

      poller.add_client(client)

      poller.listen
    rescue URI::Error, Client::Error => e
      Utils.exit_with_error(e)
    end

    private

    def print_version
      puts "v#{VERSION}"
      exit 0
    end

    def print_help
      puts <<-USAGE
Usage: acli [options]

Options:
  -u                    # URL to connect
  -c                    # Channel to subscribe to
  -m                    # Number of messages to receive before disconnect
  -v                    # Print version
  -h                    # Print this help
      USAGE
      exit 0
    end

    def ask_for_url
      @options["u"] = Utils.prompt("Enter URL: ")
    end

    def parse_options(argv)
      class << argv; include Getopts; end
      argv.getopts("vhu:c:m:")
    end
  end
end
