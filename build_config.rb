def gem_config(conf)
  conf.gembox 'default'

  # be sure to include this gem (the cli app)
  conf.gem(File.expand_path(File.dirname(__FILE__)))

  libressl_dir =
    if RUBY_PLATFORM =~ /darwin/i
      "/usr/local/opt/libressl"
    else
      "/home/mruby/opt/libressl"
    end

  # C compiler settings
  conf.cc do |cc|
    cc.include_paths << ["#{libressl_dir}/include"]
    linker.library_paths << ["#{libressl_dir}/lib"]
    linker.flags_before_libraries << [
      "#{libressl_dir}/lib/libtls.a",
      "#{libressl_dir}/lib/libssl.a",
      "#{libressl_dir}/lib/libcrypto.a"
    ]

    if RUBY_PLATFORM =~ /darwin/i
      cc.include_paths << %w(/usr/local/include)
      linker.library_paths << %w(/usr/local/lib)
    else
      cc.flags << [ENV['CFLAGS'] || %w(-fPIC -DHAVE_ARPA_INET_H)]
    end
  end
end

build_targets = ENV.fetch("BUILD_TARGET", "").split(",")

MRuby::Build.new do |conf|
  toolchain :clang

  conf.enable_bintest
  conf.enable_debug
  conf.enable_test

  gem_config(conf)
end

if build_targets.include?("Linux-x86_64")
  MRuby::Build.new("Linux-x86_64") do |conf|
    toolchain :gcc

    gem_config(conf)
  end
end

if build_targets.include?("Darwin-x86_64")
  MRuby::Build.new("Darwin-x86_64") do |conf|
    toolchain :gcc

    gem_config(conf)
  end
end
