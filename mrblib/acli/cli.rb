module Acli
  DEFAULT_CABLE_PATH = "/cable"

  class Cli
    def initialize(argv)
      @options = parse_options(argv)
    end

    def run
      url = @options.delete(:url) || ask_for_url

      uri =  URI.parse(Utils.normalize_url(url))
      uri.instance_variable_set(:@path, DEFAULT_CABLE_PATH) if uri.path.nil? || uri.path.empty?

      poller = Poller.new
      socket = Socket.new(uri)
      client = Client.new(Utils.uri_to_ws_s(uri), socket, **@options)

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
  -u, --url             # URL to connect
  -c, --channel         # Channel to subscribe to

  --quit-after          # Automatically quit after an even occured.
                        # Possible values are:
                        #  - connected — quit right after successful connection ("welcome" message)
                        #  - subscribed — quit after successful subscription to a channel
                        #  - N (integer) — quit after receiving N incoming messages (excluding pings and system messages)

  -v                    # Print version
  -h                    # Print this help
      USAGE
      exit 0
    end

    def ask_for_url
      Utils.prompt("Enter URL: ")
    end

    def parse_options(argv)
      class << argv; include Getopts; end
      argv.getopts("vhu:c:", "url:", "channel:", "headers:", "quit-after:").yield_self do |opts|
        print_version if opts["v"]
        print_help if opts["h"]

        channel = opts["c"] || opts["channel"]
        channel = nil if channel&.empty?

        quit_after = opts["quit-after"]
        quit_after = nil if quit_after&.empty?

        {
          url: opts["u"] || opts["url"],
          channel: channel,
          quit_after: quit_after
        }
      end
    end
  end
end
