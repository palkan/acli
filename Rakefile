require "fileutils"

MRUBY_VERSION = "2.1.0"

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

namespace :test do
  desc "run mruby & unit tests"
  # only build mtest for host
  task mtest: :compile do
    # in order to get mruby/test/t/synatx.rb __FILE__ to pass,
    # we need to make sure the tests are built relative from mruby_root
    MRuby.each_target do |target|
      # only run unit tests here
      target.enable_bintest = false
      run_test if target.test_enabled?
    end
  end

  def clean_env(envs)
    old_env = {}
    envs.each do |key|
      old_env[key] = ENV[key]
      ENV[key] = nil
    end
    yield
    envs.each do |key|
      ENV[key] = old_env[key]
    end
  end

  desc "run integration tests"
  task bintest: :compile do
    MRuby.each_target do |target|
      clean_env(%w(MRUBY_ROOT MRUBY_CONFIG)) do
        run_bintest if target.bintest_enabled?
      end
    end
  end
end

desc "run all tests"
Rake::Task["test"].clear
task test: ["test:bintest", "test:mtest"]

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
task rbnext: [] do
  Dir.chdir(APP_ROOT) do
    sh "ruby-next nextify ./mrblib --no-refine --min-version=2.6 --single-version"
  end
end

namespace :rbnext do
  desc "generate core extensions file"
  task core_ext: [] do
    Dir.chdir(APP_ROOT) do
      sh "ruby-next core_ext -o mrblib/acli/core_ext.rb --name=deconstruct --name=patternerror"
    end
  end
end

# Do not run Ruby Next on CI
unless ENV["CI"]
  Rake::Task["compile"].enhance [:rbnext]
end
