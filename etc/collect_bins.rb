require 'fileutils'

Dir.chdir(File.join(__dir__, "../"))

EXCLUDE_DIRS = %w(mruby/build/host mruby/build/mrbgems).freeze

FileUtils.mkdir_p("dist")

Dir["mruby/build/*"].each do |path|
  next if EXCLUDE_DIRS.include?(path)

  dir = File.basename(path)
  bin_path = File.join(path, "bin", "acli")

  next unless File.exist?(bin_path)

  FileUtils.cp(bin_path, File.join("dist", "acli-#{dir}"))
end
