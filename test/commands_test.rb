module Acli
  class TestCommands < MTest::Unit::TestCase
    class TestClient
      attr_reader :identifier
      attr_accessor :last_seen_stream, :last_seen_epoch

      def initialize(identifier = "test")
        @identifier = identifier
      end

      def close
        @closed = true
      end

      def closed?
        @closed == true
      end

      def coder
        Coders::JSON
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

    def test_namespaced_subscribe
      subject = Commands.new(client)
      assert_equal(
        "{\"command\":\"subscribe\",\"identifier\":\"{\\\"id\\\":2,\\\"name\\\":\\\"jack\\\",\\\"channel\\\":\\\"Admin::Chat\\\"}\"}",
        subject.prepare_command("\\s Admin::Chat id:2 name:'jack'")
      )
    end

    def test_perform
      subject = Commands.new(client)
      assert_equal(
        "{\"command\":\"message\",\"identifier\":\"test\",\"data\":\"{\\\"message\\\":\\\"Hello!\\\",\\\"sid\\\":123,\\\"action\\\":\\\"speak\\\"}\"}",
        subject.prepare_command("\\p speak message:\"Hello!\" sid:123")
      )
    end

    def test_history_ago
      subject = Commands.new(client)

      now_i = Time.now.to_i
      now_i_10m = now_i - 10 * 60

      command_str = subject.prepare_command("\\h since:10m")

      command = JSON.parse(command_str)

      assert_equal("history", command.fetch("command"))

      assert(command.fetch("history").fetch("since") >= now_i_10m)
      assert(command.fetch("history").fetch("since") < now_i_10m + 5)
    end

    def test_history_int
      subject = Commands.new(client)
      assert_equal(
        "{\"command\":\"history\",\"identifier\":\"test\",\"history\":{\"since\":1650634535}}",
        subject.prepare_command("\\h since:1650634535")
      )
    end

    def test_history_offset
      client.last_seen_stream = "abc"
      client.last_seen_epoch = "bc"

      subject = Commands.new(client)
      assert_equal(
        "{\"command\":\"history\",\"identifier\":\"test\",\"history\":{\"streams\":{\"abc\":{\"offset\":13,\"epoch\":\"bc\"}}}}",
        subject.prepare_command("\\h offset:13")
      )
    end
  end
end

MTest::Unit.new.run
