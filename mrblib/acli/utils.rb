module Acli
  module Utils
    def exit_with_error(e, code = 1)
      puts "Error: #{e.message}"
      exit code
    end

    def prompt(message = "Type something: ")
      print message
      STDIN.gets.chomp
    end

    def serialize(str)
      case str
      when /\A(true|t|yes|y)\z/i
        true
      when /\A(false|f|no|n)\z/i
        false
      when /\A(nil|null)\z/i
        nil
      when /\A\d+\z/
        str.to_i
      when /\A\d*\.\d+\z/
        str.to_f
      when /\A['"].*['"]\z/
        str.gsub(/(\A['"]|['"]\z)/, '')
      else
        str
      end
    end

    # Downcase and prepend with protocol if missing
    def normalize_url(url)
      url = url.downcase
      # Replace ws protocol with http, 'cause URI cannot resolve port for non-HTTP
      url.sub!("ws", "http")
      url = "http://#{url}" unless url.start_with?("http")
      url
    end

    def uri_to_ws_s(uri)
      "#{(uri.scheme == "https" || uri.scheme == "wss") ? "wss://" : "ws://"}"\
      "#{uri.userinfo ? "#{uri.userinfo}@" : ""}"\
      "#{uri.host}"\
      "#{uri.port == 80 || (uri.port == 443 && uri.scheme == "https") ? "" : ":#{uri.port}"}"\
      "#{uri.path}"\
      "#{uri.query ? "?#{uri.query}" : ""}"
    end

    extend self
  end
end
