MRuby::Gem::Specification.new("acli") do |spec|
  spec.license = "MIT"
  spec.author  = "Vladimir Dementyev"
  spec.summary = "acli"
  spec.bins    = ["acli"]

  spec.add_dependency "mruby-uri-parser", mgem: "mruby-uri-parser"
  spec.add_dependency "mruby-getopts", mgem: "mruby-getopts"
  spec.add_dependency "mruby-websockets", github: "palkan/mruby-websockets", branch: "no-tls"
end
