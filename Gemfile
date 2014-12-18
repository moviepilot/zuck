source 'http://rubygems.org'

gem 'rvm'
gem 'bundler'
gem 'koala'
gem 'activesupport'

group :development do
  gem "shoulda", "~> 3.3.2"
  gem "rdoc", "~> 3.12"
  gem "jeweler", "~> 2.0.1"
  gem "simplecov", "~> 0.7.1", :require => false
end

group :development, :test do
  gem 'webmock', '~>1.8.0'
  gem 'rspec'
  gem 'vcr'
  gem 'pry'
end

platform :ruby do
  group :development do
    gem 'guard-ctags-bundler'
    gem 'guard-rspec'
    gem 'guard-bundler'
    gem 'guard-yard'
    gem 'growl'
    gem 'redcarpet'    # Markdown for yard
    gem 'rb-fsevent'
  end
end

# platform :jruby do
#   # gem 'jruby-openssl'
# end
