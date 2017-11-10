# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_power_reviews'
  s.version     = '3-4-stable'
  s.summary     = 'integrate with power reviews into spree, download review source and show reviews on product page'
  s.description = 'integrate with power reviews into spree, download review source and show reviews on product page'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Albert Liu'
  s.email     = 'albertliu@naturalwellbeing.com'
  s.homepage  = 'http://www.naturalwellbeing.com'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  version = '3-4-stable'
  #s.add_dependency 'spree_core'
  s.add_dependency 'zip-zip'

end
