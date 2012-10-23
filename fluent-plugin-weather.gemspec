# -*- coding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-weather"
  gem.description = "Weather output plugin for Fluent"
  gem.homepage    = "https://github.com/ToQoz/fluent-plugin-weather"
  gem.summary     = "fluent-plugin-weather"
  gem.version     = File.read("VERSION").strip
  gem.authors     = ["Takatoshi Matsumoto"]
  gem.email       = "toqoz403@gmail.com"
  gem.has_rdoc    = false
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency "fluentd", "~> 0.10.7"
  gem.add_dependency "wunderground"
  gem.add_development_dependency "rake", ">= 0.9.2"
end
