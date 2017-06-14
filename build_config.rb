def gem_config(conf)
  conf.gembox 'default'

  # be sure to include this gem (the cli app)
  conf.gem(File.expand_path(File.dirname(__FILE__)))
end

build_targets = ENV.fetch("BUILD_TARGET", "").split(",")

if build_targets == %w(all)
  build_targets = %w(
    linux-x86_64
    darwin-x86_64
  )
end

MRuby::Build.new do |conf|
  toolchain :clang

  conf.enable_bintest
  conf.enable_debug
  conf.enable_test

  # C compiler settings
  conf.cc do |cc|
    if RUBY_PLATFORM =~ /darwin/i
      cc.include_paths << %w(/usr/local/include /usr/local/opt/openssl/include /usr/local/opt/libressl/include)
      linker.library_paths << %w(/usr/local/lib /usr/local/opt/openssl/lib /usr/local/opt/libressl/lib)
    else
      cc.flags << [ENV['CFLAGS'] || %w(-fPIC -DHAVE_ARPA_INET_H)]
      cc.include_paths << %w(/home/mruby/opt/libressl/include)
      linker.library_paths << %w(/home/mruby/opt/libressl/lib)
    end
  end

  gem_config(conf)
end

if build_targets.include?("linux-x86_64")
  MRuby::Build.new("linux-x86_64") do |conf|
    toolchain :clang

    # C compiler settings
    conf.cc do |cc|
      cc.flags << [ENV['CFLAGS'] || %w(-fPIC -DHAVE_ARPA_INET_H)]
      cc.include_paths << %(/home/mruby/opt/libressl/include)
      linker.library_paths << %w(/home/mruby/opt/libressl/lib)
    end

    gem_config(conf)
  end
end

if build_targets.include?("darwin-x86_64")
  MRuby::Build.new("macos-x86_64") do |conf|
    toolchain :clang

    # C compiler settings
    conf.cc do |cc|
      cc.include_paths << %w(/usr/local/include /usr/local/opt/openssl/include)
      linker.library_paths << %w(/usr/local/lib /usr/local/opt/openssl/lib /usr/local/opt/libressl/lib)
    end

    gem_config(conf)
  end
end
