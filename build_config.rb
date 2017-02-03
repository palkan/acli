def gem_config(conf)
  conf.gembox 'default'

  # be sure to include this gem (the cli app)
  conf.gem(File.expand_path(File.dirname(__FILE__)))
end

MRuby::Build.new do |conf|
  toolchain :clang

  # conf.enable_bintest
  # conf.enable_debug
  # conf.enable_test

  # C compiler settings
  conf.cc do |cc|
    if RUBY_PLATFORM =~ /darwin/i
      cc.include_paths << %w(/usr/local/include /usr/local/opt/openssl/include)
      linker.library_paths << %w(/usr/local/lib /usr/local/opt/openssl/lib)

    else
      cc.flags << [ENV['CFLAGS'] || %w(-fPIC -DHAVE_ARPA_INET_H)]
      cc.include_paths << %(/root/wslay/lib)
    end
  end

  gem_config(conf)
end

build_targets = ENV.fetch("BUILD_TARGET", "").split(",")

if build_targets == %w(all)
  build_targets = %w(
    linux-x86_64
    linux-i686
    darwin-x86_64
    darwin-i386
    mingw-x86_64
    mingw-i686
  )
end

if build_targets.include?("linux-x86_64")
  MRuby::Build.new("x86_64-pc-linux-gnu") do |conf|
    toolchain :gcc

    # C compiler settings
    conf.cc do |cc|
      cc.flags << [ENV['CFLAGS'] || %w(-fPIC -DHAVE_ARPA_INET_H)]
      cc.include_paths << %(/root/wslay/lib)
    end

    gem_config(conf)
  end
end

if build_targets.include?("linux-i686")
  MRuby::CrossBuild.new("i686-pc-linux-gnu") do |conf|
    toolchain :gcc

    [conf.cc, conf.cxx, conf.linker].each do |cc|
      cc.flags << "-m32"
    end

    gem_config(conf)
  end
end

if build_targets.include?("darwin-x86_64")
  MRuby::CrossBuild.new("x86_64-apple-darwin15") do |conf|
    toolchain :clang

    [conf.cc, conf.linker].each do |cc|
      cc.command = "x86_64-apple-darwin15-clang"
    end
    conf.cxx.command      = "x86_64-apple-darwin15-clang++"
    conf.archiver.command = "x86_64-apple-darwin15-ar"

    conf.build_target     = "x86_64-pc-linux-gnu"
    conf.host_target      = "x86_64-apple-darwin15"

    gem_config(conf)
  end
end

if build_targets.include?("darwin-i386")
  MRuby::CrossBuild.new("i386-apple-darwin15") do |conf|
    toolchain :clang

    [conf.cc, conf.linker].each do |cc|
      cc.command = "i386-apple-darwin15-clang"
    end
    conf.cxx.command      = "i386-apple-darwin15-clang++"
    conf.archiver.command = "i386-apple-darwin15-ar"

    conf.build_target     = "i386-pc-linux-gnu"
    conf.host_target      = "i386-apple-darwin15"

    gem_config(conf)
  end
end

if build_targets.include?("mingw-x86_64")
  MRuby::CrossBuild.new("x86_64-w64-mingw32") do |conf|
    toolchain :gcc

    [conf.cc, conf.linker].each do |cc|
      cc.command = "x86_64-w64-mingw32-gcc"
    end
    conf.cxx.command      = "x86_64-w64-mingw32-cpp"
    conf.archiver.command = "x86_64-w64-mingw32-gcc-ar"
    conf.exts.executable  = ".exe"

    conf.build_target     = "x86_64-pc-linux-gnu"
    conf.host_target      = "x86_64-w64-mingw32"

    gem_config(conf)
  end
end

if build_targets.include?("mingw-i686")
  MRuby::CrossBuild.new("i686-w64-mingw32") do |conf|
    toolchain :gcc

    [conf.cc, conf.linker].each do |cc|
      cc.command = "i686-w64-mingw32-gcc"
    end
    conf.cxx.command      = "i686-w64-mingw32-cpp"
    conf.archiver.command = "i686-w64-mingw32-gcc-ar"
    conf.exts.executable  = ".exe"

    conf.build_target     = "i686-pc-linux-gnu"
    conf.host_target      = "i686-w64-mingw32"

    gem_config(conf)
  end
end
