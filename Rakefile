# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "zuck"
  gem.homepage = "http://github.com/jayniz/zuck"
  gem.license = "MIT"
  gem.summary = %Q{Ruby adapter to facebook's ad api}
  gem.description = %Q{This gem allows to easily access facebook's ads api in ruby. See https://developers.facebook.com/docs/reference/ads-api/}
  gem.email = "jannis@gmail.com"
  gem.authors = ["Jannis Hermanns"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new


task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "zuck #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
