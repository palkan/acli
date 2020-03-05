module Acli
  class Poller
    attr_reader :poll, :stdin, :client

    def initialize
      @poll = Poll.new
      @stdin = poll.add(STDIN_FILENO, Poll::In)
    end

    def add_client(client)
      @client = client

      client.socket.setup_poller(poll)
    end

    def listen
      while ready_fds = poll.wait
        ready_fds.each do |ready_fd|
          if ready_fd == stdin
            handle_stdin
          else
            frame = client.socket.receive_frame
            next unless frame
            client.handle_incoming(frame)
          end
        end
      end
    rescue => e
      puts "Unexpected close: #{e}\n#{e.backtrace}"
      raise
    ensure
      client.close
    end

    private

    def handle_stdin
      command = STDIN.gets&.chomp
      return unless command
      stdin.events = 0
      client.handle_command(command) if command.length > 0
    ensure
      stdin.events = Poll::In
    end
  end
end
