def gem_config(conf)
  conf.gembox 'default'

  # be sure to include this gem (the cli app)
  conf.gem(File.expand_path(File.dirname(__FILE__)))
end

MRuby::Build.new do |conf|
  if ENV['CC'] == 'clang'
    toolchain :clang
  else
    toolchain :gcc
  end

  conf.enable_bintest
  conf.enable_debug
  conf.enable_test

  # C compiler settings
  conf.cc do |cc|
    cc.flags << [ENV['CFLAGS'] || %w(-fPIC -DHAVE_ARPA_INET_H)]
    cc.include_paths << ["#{ENV['HOME']}/opt/libressl/include"]
    linker.library_paths << ["#{ENV['HOME']}/opt/libressl/lib"]
  end

  gem_config(conf)
end
