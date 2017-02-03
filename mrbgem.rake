MRuby::Gem::Specification.new("acli") do |spec|
  spec.license = "MIT"
  spec.author  = "Vladimir Dementyev"
  spec.summary = "acli"
  spec.bins    = ["acli"]

  spec.add_dependency "mruby-uri-parser", core: "mruby-uri-parser"
  spec.add_dependency "mruby-getopts", core: "mruby-getopts"
  spec.add_dependency "mruby-websockets", core: "mruby-websockets"
  spec.add_dependency "mruby-poll", core: "mruby-poll"
end
