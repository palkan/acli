module Acli
  class ClientTest < MTest::Unit::TestCase
    class FakeSocket
      def close
        @closed = true
      end

      def closed?
        @closed
      end
    end

    def test_handle_incoming_ping
      client = Client.new("", nil)

      assert_nil client.last_ping_at
      client.handle_incoming(%({"type":"ping"}))

      assert !client.last_ping_at.nil?
    end

    def test_handle_incoming_welcome
      client = Client.new("", nil)

      assert !client.connected?
      client.handle_incoming(%({"type":"welcome"}))

      assert client.connected?
    end

    def test_handle_incoming_subscribed
      client = Client.new("", nil)

      assert_nil client.identifier
      client.handle_incoming(%({"type":"confirm_subscription","identifier":"test_channel"}))

      assert_equal "test_channel", client.identifier
    end

    def test_handle_disconnect
      socket = FakeSocket.new
      client = Client.new("", socket)
      # Avoid exiting, 'cause it halts tests execution
      client.define_singleton_method(:exit) {|*|}

      client.handle_incoming(%({"type":"disconnect","reason":"server_restart", "reconnect": true}))

      assert socket.closed?
    end

    def test_unknown_message
      client = Client.new("", nil)

      assert_raise(NoMatchingPatternError) { client.handle_incoming(%({"typo":"confirm_subscription"})) }
    end
  end
end

MTest::Unit.new.run
