require_relative ".rbnext"
using MRubyNext

MRuby::Gem::Specification.new("acli") do |spec|
  spec.license = "MIT"
  spec.author  = "Vladimir Dementyev"
  spec.summary = "acli"
  spec.bins    = ["acli"]

  spec.setup_ruby_next!

  spec.add_dependency "mruby-exit", core: "mruby-exit"
  spec.add_dependency "mruby-string-ext", core: "mruby-string-ext"
  spec.add_dependency "mruby-hash-ext", core: "mruby-hash-ext"
  spec.add_dependency "mruby-kernel-ext", core: "mruby-kernel-ext"
  spec.add_dependency "mruby-struct", core: "mruby-struct"
  spec.add_dependency "mruby-enumerator", core: "mruby-enumerator"

  spec.add_dependency "mruby-json", github: "palkan/mruby-json"
  spec.add_dependency "mruby-regexp-pcre", mgem: "mruby-regexp-pcre"
  # Pinned: master is now C++ (ada-url), which flips the whole build into
  # MRB_USE_CXX_EXCEPTION mode and breaks mruby 3.0.0 presym scanning
  spec.add_dependency "mruby-uri-parser", github: "Asmod4n/mruby-uri-parser", checksum_hash: "bbfb475e3125bb7edf50aae110f5d5a64f4e3f6a"
  spec.add_dependency "mruby-getopts", mgem: "mruby-getopts"

  # Pinned: master builds its bundled LibreSSL 4.0 via cmake instead of
  # linking the system one provided via LIBRESSL_DIR (build targets don't
  # use build_config.rb.lock, so transitive deps must be pinned explicitly)
  spec.add_dependency "mruby-tls", github: "Asmod4n/mruby-tls", checksum_hash: "af809343feb18d11b97d346072e15ab736f1ac3f"
  spec.add_dependency "mruby-websockets", github: "Asmod4n/mruby-websockets"
  spec.add_dependency "mruby-simplemsgpack", github: "palkan/mruby-simplemsgpack"

  spec.add_test_dependency "mruby-mtest", mgem: "mruby-mtest"
end
