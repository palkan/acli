module Acli
  class TestCommands < MTest::Unit::TestCase
    class TestClient
      attr_reader :identifier

      def initialize(identifier = "test")
        @identifier = identifier
      end

      def close
        @closed = true
      end

      def closed?
        @closed == true
      end
    end

    def client
      @client ||= TestClient.new
    end

    def test_quit
      subject = Commands.new(client)
      subject.prepare_command "\\q"
      assert client.closed?
    end

    def test_subscribe
      subject = Commands.new(client)
      assert_equal(
        "{\"command\":\"subscribe\",\"identifier\":\"{\\\"id\\\":2,\\\"channel\\\":\\\"chat\\\"}\"}",
        subject.prepare_command("\\s chat id:2")
      )
    end

    def test_perform
      subject = Commands.new(client)
      assert_equal(
        "{\"command\":\"message\",\"identifier\":\"test\",\"data\":\"{\\\"message\\\":\\\"Hello!\\\",\\\"sid\\\":123,\\\"action\\\":\\\"speak\\\"}\"}",
        subject.prepare_command("\\p speak message:\"Hello!\" sid:123")
      )
    end
  end
end

MTest::Unit.new.run
