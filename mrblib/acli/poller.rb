module Acli
  class Poller
    attr_reader :poll, :stdin, :socket_fd, :client

    def initialize
      @poll = Poll.new
      @stdin = poll.add(STDIN_FILENO, Poll::In)
    end

    def add_client(client)
      @client = client

      @socket_fd = client.socket.setup_poller(poll)
    end

    def listen
      expect_stdin = false
      while ready_fds = poll.wait
        ready_fds.each do |ready_fd|
          if ready_fd == stdin
            expect_stdin = false
            handle_stdin
          else
            frame = client.socket.receive_frame
            next client.handle_incoming(frame) if frame

            # there is a bug (?) in poll/socket, which activates
            # socket fd for read right before stdin
            if expect_stdin
              raise Acli::ClonnectionClosedError, "Connection closed unexpectedly"
            end
            expect_stdin = true
          end
        end
      end
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
