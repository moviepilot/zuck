source 'http://rubygems.org'

gem 'bundler'
gem 'koala', '~>1.6.0'
gem 'activesupport'

group :development do
  gem "jeweler", "~> 2.0.1"
  gem "rdoc", "~> 3.12"
  gem "shoulda", "~> 3.3.2"
  gem "simplecov", "~> 0.7.1", :require => false
end

group :development, :test do
  gem 'dotenv'
  gem 'pry'
  gem 'rspec'
  gem 'vcr'
  gem 'webmock', '~>1.8.0'
end

platform :ruby do
  group :development do
    gem 'growl'
    gem 'guard'
    gem 'guard-bundler'
    gem 'guard-rspec'
    gem 'guard-yard'
    gem 'rb-fsevent'
    gem 'redcarpet'    # Markdown for yard
  end
end
