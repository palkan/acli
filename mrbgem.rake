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
  # Pinned: masters were rewritten in C++; any gem with C++ sources makes
  # mruby auto-enable MRB_USE_CXX_EXCEPTION, which breaks 3.0.0 presym scanning
  spec.add_dependency "mruby-wslay", github: "Asmod4n/mruby-wslay", checksum_hash: "47fc6c9795399efb4bcf2258a69125afcab00428"
  spec.add_dependency "mruby-poll", github: "Asmod4n/mruby-poll", checksum_hash: "f33ce28bc3ebb8650d91a0bf31da3e163e29af45"
  spec.add_dependency "mruby-string-is-utf8", github: "Asmod4n/mruby-string-is-utf8", checksum_hash: "1c639fe845008d437420a61852329a158ddd74b1"
  spec.add_dependency "mruby-phr", github: "Asmod4n/mruby-phr", checksum_hash: "1bab77000280141802d56a20a5413ba0900b69df"
  spec.add_dependency "mruby-sysrandom", github: "Asmod4n/mruby-sysrandom", checksum_hash: "75347e898686c8c044b0fa8a76f42ad25daee45c"
  spec.add_dependency "mruby-b64", github: "Asmod4n/mruby-b64", checksum_hash: "6d8f36b1bd310aa1b0dccd6fe7b0e9d7551d7718"
  spec.add_dependency "mruby-secure-compare", github: "Asmod4n/mruby-secure-compare", checksum_hash: "433a73a483b550ad13e3a9af33707300c1c7822d"
  spec.add_dependency "mruby-websockets", github: "Asmod4n/mruby-websockets", checksum_hash: "9bb66308085acbeb727f8ef21979b7884d8fb322"
  spec.add_dependency "mruby-simplemsgpack", github: "palkan/mruby-simplemsgpack"

  spec.add_test_dependency "mruby-mtest", mgem: "mruby-mtest"
end
