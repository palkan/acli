require "open3"

BIN_PATH = File.join(File.dirname(__FILE__), "../mruby/bin/acli")

assert("with invalid url") do
  output, status = Open3.capture2(BIN_PATH, "-u", "localhost:0:1:2")

  assert_false status.success?, "Process exited cleanly"
  assert_include output, "Error: "
end

assert("version") do
  output, status = Open3.capture2(BIN_PATH, "-v")

  assert_true status.success?, "Process did not exit cleanly"
  assert_include output, "v0.0.1"
end

assert("help") do
  output, status = Open3.capture2(BIN_PATH, "-h")

  assert_true status.success?, "Process did not exit cleanly"
  assert_include(
    output,
    "Usage: acli [options]"
  )
end
