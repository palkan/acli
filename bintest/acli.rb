require_relative "../mrblib/acli/version"
require "socket"
require "json"
require "childprocess"

BIN_PATH = File.join(File.dirname(__FILE__), "../mruby/bin/acli")

class AcliProcess
  attr_reader :process, :wio, :rio

  def initialize(*args, bin: BIN_PATH)
    @rio, @wio = IO.pipe
    @process = ChildProcess.build(bin, *args)
    process.io.stdout = process.io.stderr = @wio
    process.duplex = true
  end

  def running
    process.start
    yield process
  ensure
    process.stop
  end

  def readline(time = 0.99)
    line = nil
    thread = Thread.new { line = rio.readline }

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
  acli = AcliProcess.new("-u", "localhost:80:80")
  acli.running do |process|
    assert_include acli.readline, "Error: "
    assert_false process.alive?
    assert_equal 1, process.exit_code
  end
end

assert("version") do
  acli = AcliProcess.new("-v")

  acli.running do |process|
    assert_include acli.readline, "v#{Acli::VERSION}"
    assert_false process.alive?
    assert_equal 0, process.exit_code
  end
end

assert("help") do
  acli = AcliProcess.new("-h")

  acli.running do |process|
    assert_include(
      acli.readline,
      "Usage: acli [options]"
    )
    assert_false process.alive?
    assert_equal 0, process.exit_code
  end
end

SERVER_RUNNING =
  begin
    server_process = AcliProcess.new(bin: File.join(__dir__, "../etc/server.rb"))
    $stdout.puts "\nStarting test server..."
    server_process.process.leader = true
    server_process.process.start

    # Wait 'till server is ready
    loop do
      line = server_process.readline
      if line =~ /Listening on/
        $stdout.puts "Server started"
        at_exit { server_process.process.stop }
        break true
      end

      break false unless server_process.process.alive?

      sleep 1 if line =~ /Timed out/
    end
  end

return $stdout.puts("Skip integration tests: server is not runnnig") unless SERVER_RUNNING

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

assert("handles subsciption rejection") do
  acli = AcliProcess.new("-u", "localhost:8080")
  acli.running do |process|
    assert_true process.alive?, "Process failed"
    assert_include(
      acli.readline,
      "Connected to Action Cable"
    )

    acli.puts '\s ProtectedChannel'

    assert_include(
      acli.readline,
      "Subscription rejected"
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

assert("connects with header") do
  acli = AcliProcess.new("-u", "localhost:8080", "-c", "EchoChannel", "--headers", "x-api-token:secretos")
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
      {token: "secretos"}.to_json
    )
  end
end

assert("connects with multiple headers") do
  acli = AcliProcess.new("-u", "localhost:8080", "-c", "EchoChannel", "--headers", "x-api-token:secretos,x-api-gate:21")
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

    acli.puts '\p echo_headers'
    assert_include(
      acli.readline,
      [["HTTP_X_API_TOKEN","secretos"],["HTTP_X_API_GATE", "21"]].to_json
    )
  end
end

assert("connects with cookie header") do
  acli = AcliProcess.new("-u", "localhost:8080", "-c", "EchoChannel", "--headers", "cookie:token=nookie")
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
      {token: "nookie"}.to_json
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
