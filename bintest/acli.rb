require_relative "../mrblib/acli/version"
require "socket"
require "json"

BIN_PATH = File.join(File.dirname(__FILE__), "../mruby/bin/acli")

# Skip integration tests if server is not running.
#
# Run server using the following command (from tha project's root):
#
#    ruby etc/server.rb
#
SERVER_RUNNING =
  begin
    Socket.tcp("localhost", 8080, connect_timeout: 1).close
    true
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
    false
  end

class AcliProcess
  attr_reader :process, :wio, :rio

  def initialize(*args)
    @rio, @wio = IO.pipe
    @process = ChildProcess.build(BIN_PATH, *args)
    process.io.stdout = process.io.stderr = @wio
    process.duplex = true
  end

  def running
    process.start
    yield process
  ensure
    process.stop
  end

  def readline
    line = nil
    thread = Thread.new { line = rio.readline }

    time = 0.99

    loop do
      return line if line
      sleep 0.2

      time -= 0.2

      if time < 0
        thread.terminate
        return "<Timed out to read from the process>"
      end
    end
  end

  def puts(*args)
    process.io.stdin.puts(*args)
  end
end

assert("with invalid url") do
  output, status = Open3.capture2(BIN_PATH, "-u", "localhost:0:1:2")

  assert_false status.success?, "Process exited cleanly"
  assert_include output, "Error: "
end

assert("version") do
  output, status = Open3.capture2(BIN_PATH, "-v")

  assert_true status.success?, "Process did not exit cleanly"
  assert_include output, "v#{Acli::VERSION}"
end

assert("help") do
  output, status = Open3.capture2(BIN_PATH, "-h")

  assert_true status.success?, "Process did not exit cleanly"
  assert_include(
    output,
    "Usage: acli [options]"
  )
end

return $stdout.puts("Skip integration tests: server is not runnnig") unless SERVER_RUNNING

require "childprocess"

assert("connects successfully") do
  acli = AcliProcess.new("-u", "localhost:8080")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(acli.readline, "Connected to Action Cable at ws://localhost:8080/cable")
  end
end

assert("connects with query") do
  acli = AcliProcess.new("-u", "localhost:8080/cable?token=secret#page=home")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(
      acli.readline,
      "Connected to Action Cable at ws://localhost:8080/cable?token=secret"
    )
  end
end

assert("subscribes to a channel") do
  acli = AcliProcess.new("-u", "localhost:8080")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(
      acli.readline,
      "Connected to Action Cable"
    )

    acli.puts '\s DemoChannel'
    assert_include(
      acli.readline,
      "Subscribed to DemoChannel"
    )
  end
end

assert("subscribes to a channel with int param") do
  acli = AcliProcess.new("-u", "localhost:8080")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(
      acli.readline,
      "Connected to Action Cable"
    )

    acli.puts '\s EchoChannel param:1'
    assert_include(
      acli.readline,
      "Subscribed to EchoChannel"
    )

    acli.puts '\p echo_params'
    assert_include(
      acli.readline,
      {param: 1}.to_json
    )
  end
end

assert("subscribes to a channel with string param") do
  acli = AcliProcess.new("-u", "localhost:8080")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(
      acli.readline,
      "Connected to Action Cable"
    )

    acli.puts '\s EchoChannel param:"Test"'
    assert_include(
      acli.readline,
      "Subscribed to EchoChannel"
    )

    acli.puts '\p echo_params'
    assert_include(
      acli.readline,
      {param: "Test"}.to_json
    )
  end
end

assert("performs action") do
  acli = AcliProcess.new("-u", "localhost:8080", "--channel", "EchoChannel")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(
      acli.readline,
      "Connected to Action Cable"
    )
    assert_include(
      acli.readline,
      "Subscribed to EchoChannel"
    )

    acli.puts '\p echo msg:"hello"'
    assert_include(
      acli.readline,
      {pong: {msg: "hello"}}.to_json
    )
  end
end

assert("request query is supported") do
  acli = AcliProcess.new("-u", "localhost:8080/cable?token=s3cr3t", "-c", "EchoChannel")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(
      acli.readline,
      "Connected to Action Cable"
    )
    assert_include(
      acli.readline,
      "Subscribed to EchoChannel"
    )

    acli.puts '\p echo_token'
    assert_include(
      acli.readline,
      {token: "s3cr3t"}.to_json
    )
  end
end

assert("quit after connect") do
  acli = AcliProcess.new("--url", "localhost:8080", "--quit-after", "connect")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(
      acli.readline,
      "Connected to Action Cable"
    )
    assert_false process.alive?
  end
end

assert("quit after subscribed") do
  acli = AcliProcess.new("--url", "localhost:8080", "-c", "DemoChannel", "--quit-after", "subscribed")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(
      acli.readline,
      "Connected to Action Cable"
    )
    assert_include(
      acli.readline,
      "Subscribed to DemoChannel"
    )
    assert_false process.alive?
  end
end

assert("quit after N") do
  acli = AcliProcess.new("--url", "localhost:8080", "-c", "EchoChannel", "--quit-after", "2")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(
      acli.readline,
      "Connected to Action Cable"
    )
    assert_include(
      acli.readline,
      "Subscribed to EchoChannel"
    )

    acli.puts '\p echo_token'
    assert_include(acli.readline, "token")

    acli.puts '\p echo_token'
    assert_include(acli.readline, "token")

    assert_false process.alive?
  end
end
