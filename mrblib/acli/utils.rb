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

    extend self
  end
end
