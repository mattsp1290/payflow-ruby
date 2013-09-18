# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'payflow/version'

Gem::Specification.new do |gem|
  gem.name          = "payflow"
  gem.version       = Payflow::VERSION
  gem.authors       = ["Jonathan Spies", "Ben Bean", "Justin Litchfield"]
  gem.email         = ["jonathan.spies@gmail.com"]
  gem.description   = %q{A Ruby Library wrapper to the Payflow Gateway. This gem was created specifically to add magnetic card reader and decryption support not found in any other Payflow gems.}
  gem.summary       = %q{Does Transactions against Payflow Gateway. Supports encrypted swipes and reporting.}
  gem.homepage      = "http://github.com/bypasslane/payflow-ruby"
  gem.licenses      = "MIT"

  gem.add_dependency "activemodel", ">=3.1.12"
  gem.add_dependency "nokogiri", "~>1.5.9"
  gem.add_dependency "builder", ">=3.0.0"
  gem.add_dependency "faraday", "~>0.8.7"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency "rspec"
end
