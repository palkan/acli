require "fileutils"

MRUBY_VERSION = "3.2.0"

task :mruby do
  sh "git clone --branch=#{MRUBY_VERSION} --depth=1 https://github.com/mruby/mruby"
end

APP_NAME = ENV["APP_NAME"] || "acli"
APP_ROOT = ENV["APP_ROOT"] || Dir.pwd
# avoid redefining constants in mruby Rakefile
mruby_root = File.expand_path(ENV["MRUBY_ROOT"] || "#{APP_ROOT}/mruby")
mruby_config = File.expand_path(ENV["MRUBY_CONFIG"] || "build_config.rb")
ENV["MRUBY_ROOT"] = mruby_root
ENV["MRUBY_CONFIG"] = mruby_config

Rake::Task[:mruby].invoke unless Dir.exist?(File.join(mruby_root, "lib"))

Dir.chdir(mruby_root)
load "#{mruby_root}/Rakefile"

desc "compile binary"
task compile: [:all] do
  %W(#{mruby_root}/build/x86_64-pc-linux-gnu/bin/#{APP_NAME} #{mruby_root}/build/i686-pc-linux-gnu/#{APP_NAME}").each do |bin|
    sh "strip --strip-unneeded #{bin}" if File.exist?(bin)
  end
end

Rake::Task["test"].clear
desc "run all tests"
task test: ["nextify", "test:build:lib", "test:run:lib", "test:run:bin"]

desc "cleanup"
task :clean do
  sh "rake deep_clean"
end

desc "clean host build without deleting gems"
task :host_clean do
  sh "rm -rf #{File.join(mruby_root, "build", "host")}"
end

desc "run build"
task run: :default do
  exec File.join(mruby_root, "bin", APP_NAME)
end

desc "run mirb"
task irb: :default do
  exec File.join(mruby_root, "bin", "mirb")
end

Rake::Task["run"].clear

desc "run compiled binary"
task run: :compile do
  args =
    if (split_index = ARGV.index("--"))
      ARGV[(split_index+1)..-1]
    else
      []
    end

  sh "bin/acli #{args.join(" ")}"
end

desc "transpile source code with ruby-next"
task :nextify do
  Dir.chdir(APP_ROOT) do
    sh "ruby-next nextify -V"
  end
end

namespace :rbnext do
  desc "generate core extensions file"
  task core_ext: [] do
    Dir.chdir(APP_ROOT) do
      sh "ruby-next core_ext -o mrblib/acli/core_ext.rb"
    end
  end
end

Rake::Task[:gensym].enhance [:nextify]
