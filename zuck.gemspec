Gem::Specification.new do |s|
  s.name        = 'zuck'
  s.version     = '4.0.0'
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.authors     = ['Chris Estreich']
  s.email       = 'cestreich@gmail.com'
  s.homepage    = 'https://github.com/cte/zuck'
  s.summary     = "Ruby adapter to Facebook's Marketing API."
  s.description = "This gem allows to easily access Facebook's Marketing API in ruby. See https://developers.facebook.com/docs/reference/ads-api/"

  s.extra_rdoc_files = ['README.markdown']

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '~> 2.0'

  s.add_dependency 'activesupport'
  s.add_dependency 'httparty'
  s.add_dependency 'httmultiparty'

  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'builder'
end
