
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "feedium/version"

Gem::Specification.new do |spec|
  spec.name          = "feedium"
  spec.version       = Feedium::VERSION
  spec.authors       = ["Alex"]
  spec.email         = ["bagirs@gmail.com"]

  spec.summary       = %q{Write a short summary, because RubyGems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/Stajor/feedium'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency 'open_uri_redirections', '~> 0.2'
  spec.add_dependency 'nokogiri', '~> 1.8'
  spec.add_dependency 'feedjira', '~> 2.1'
end
