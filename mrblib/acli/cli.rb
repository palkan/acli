module Acli
  class Cli
    def initialize(argv)
      @options = parse_options(argv)
    end

    def run
      print_version if @options["v"]
      print_help if @options["h"]
      ask_for_url unless @options["u"]
      Client.new(@options["u"])
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
      argv.getopts("vhu:")
    end
  end
end
