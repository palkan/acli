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

    extend self
  end
end
