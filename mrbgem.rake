MRuby::Gem::Specification.new("acli") do |spec|
  spec.license = "MIT"
  spec.author  = "Vladimir Dementyev"
  spec.summary = "acli"
  spec.bins    = ["acli"]

  spec.add_dependency "mruby-exit", core: "mruby-exit"
  spec.add_dependency "mruby-string-ext", core: "mruby-string-ext"
  spec.add_dependency "mruby-hash-ext", core: "mruby-hash-ext"
  spec.add_dependency "mruby-kernel-ext", core: "mruby-kernel-ext"
  spec.add_dependency "mruby-struct", core: "mruby-struct"

  spec.add_dependency "mruby-json", mgem: "mruby-json"
  spec.add_dependency "mruby-regexp-pcre", mgem: "mruby-regexp-pcre"
  spec.add_dependency "mruby-uri-parser", mgem: "mruby-uri-parser"
  spec.add_dependency "mruby-getopts", mgem: "mruby-getopts"

  spec.add_dependency "mruby-websockets", github: "palkan/mruby-websockets", branch: "no-tls"

  spec.add_test_dependency "mruby-mtest", mgem: "mruby-mtest"
end
