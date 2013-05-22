# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ocf_parser/version"

Gem::Specification.new do |s|
  s.name        = "ocf_parser"
  s.version     = OcfParser::VERSION
  s.authors     = ["yincan"]
  s.email       = ["shengyincan@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Parse the ocf file}
  s.description = %q{ocf files are used in china mobile reading base, this gem is going to parse that file}

  s.rubyforge_project = "ocf_parser"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", ">= 2"
  s.add_runtime_dependency "nokogiri", ">= 1.5.0"
  s.add_runtime_dependency "rubyzip", ">= 0.9.6"
end
