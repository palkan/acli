module Acli
  DEFAULT_CABLE_PATH = "/cable"
  class Cli
    def initialize(argv)
      @options = parse_options(argv)
    end
    def run
      url = (@options.delete(:url) || ask_for_url)
      uri = URI.parse(Utils.normalize_url(url))
      if (uri.path.nil? || uri.path.empty?)
        uri.instance_variable_set(:@path, DEFAULT_CABLE_PATH)
      end
      poller = Poller.new
      socket = Socket.new(uri, @options.delete(:headers))
      client = Client.new(Utils.uri_to_ws_s(uri), socket, **@options)
      poller.add_client(client)
      poller.listen
    rescue URI::Error, Client::Error => e
      Utils.exit_with_error(e)
    end
    private
    def print_version
      puts("#{"v"}#{VERSION}")
      exit(0)
    end
    def print_help
      puts("#{"Usage: acli [options]\n"}#{"\n"}#{"Options:\n"}#{"  -u, --url             # URL to connect\n"}#{"  -c, --channel         # Channel to subscribe to\n"}#{"\n"}#{"  --headers             # Additional HTTP headers in a form \"<k>:<v>\" separated by \",\"\n"}#{"                        # Example: `--headers=\"x-api-token:secret,cookie:user_id=26\"`\n"}#{"                        # NOTE: the value should not contain whitespaces.\n"}#{"\n"}#{"  --quit-after          # Automatically quit after an even occured.\n"}#{"                        # Possible values are:\n"}#{"                        #  - connected — quit right after successful connection (\"welcome\" message)\n"}#{"                        #  - subscribed — quit after successful subscription to a channel\n"}#{"                        #  - N (integer) — quit after receiving N incoming messages (excluding pings and system messages)\n"}#{"\n"}#{"  -v                    # Print version\n"}#{"  -h                    # Print this help\n"}")
      exit(0)
    end
    def ask_for_url
      Utils.prompt("Enter URL: ")
    end
    def parse_options(argv)
      class << argv
        include(Getopts)
      end
      argv.getopts("vhu:c:", "url:", "channel:", "headers:", "quit-after:").yield_self do |opts|
        if opts["v"]
          print_version
        end
        if opts["h"]
          print_help
        end
        headers = if opts["headers"]
          opts["headers"].split(",")
        end
        { url: (opts["u"] || opts["url"]), channel: (opts["c"] || opts["channel"]), quit_after: opts["quit-after"], headers: headers }.tap do |data|
          data.delete_if do |_1, _2|
            _2.empty?
          end
        end
      end
    end
  end
end