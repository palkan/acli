def gem_config(conf)
  conf.gembox 'default'

  # be sure to include this gem (the cli app)
  conf.gem(File.expand_path(File.dirname(__FILE__)))
end

MRuby::Build.new do |conf|
  toolchain :clang

  conf.enable_bintest
  conf.enable_debug
  conf.enable_test

  # C compiler settings
  conf.cc do |cc|
    cc.flags << [ENV['CFLAGS'] || %w(-fPIC -DHAVE_ARPA_INET_H)]
    cc.include_paths << ["#{ENV['HOME']}/wslay/lib", "#{ENV['HOME']}/libsodium/include"]

    linker.libraries << %w(ssl crypto)
  end

  gem_config(conf)
end
