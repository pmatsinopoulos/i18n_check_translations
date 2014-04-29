# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i18n_check_translations/version'

Gem::Specification.new do |spec|
  spec.name          = "i18n_check_translations"
  spec.version       = I18nCheckTranslations::VERSION
  spec.authors       = ["Panayotis Matsinopoulos"]
  spec.email         = ["panayotis@matsinopoulos.gr"]
  spec.summary       = %q{Checks your consistency of your translations and can be helpful to find missing ones.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", File.join("lib", "tasks")]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
