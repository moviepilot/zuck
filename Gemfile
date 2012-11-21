source 'http://rubygems.org'
source 'http://moviepilot:GoodMovies@gems.backend.moviepilot.com'

gem 'rvm'
gem 'bundler'
gem 'koala', '~>1.5'
gem 'activesupport'

group :development do
  gem "shoulda", ">= 0"
  gem "rdoc", "~> 3.12"
  gem "jeweler", "~> 1.8.4"
  gem "simplecov", ">= 0", :require => false
end

group :development, :test do
  gem 'webmock'
  gem 'rspec'
  gem 'vcr'
end

platform :ruby do
  group :development, :test do
    gem 'guard'
    gem 'guard-rspec'
    gem 'guard-bundler'
    gem 'guard-yard'
    gem 'debugger'
    gem 'growl'
    gem 'redcarpet'    # Markdown for yard
  end
end

platform :jruby do
  gem 'jruby-openssl'
end
