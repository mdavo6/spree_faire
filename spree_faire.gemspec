# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_faire/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_faire'
  s.version     = SpreeFaire.version
  s.summary     = 'Spree integration for Faire marketplace'
  s.description = 'Import orders from Faire into Spree and update inventory levels'
  s.required_ruby_version = '>= 2.5'

  s.author    = 'Michael Davidson'
  s.email     = 'michael@boldb.com.au'
  s.homepage  = 'https://github.com/mdavo6/spree_faire'
  s.license = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree', '~> 4.2'
  s.add_dependency 'httparty', '~> 0.15.6'
  # s.add_dependency 'spree_backend' # uncomment to include Admin Panel changes
  s.add_dependency 'spree_extension'

  s.add_development_dependency 'spree_dev_tools'
end
