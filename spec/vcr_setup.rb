# VCR Config
require 'vcr'

VCR.configure do |c|
  dir = File.expand_path("../../spec/fixtures", __FILE__)
  c.cassette_library_dir      = dir
  c.hook_into                 :webmock
  c.ignore_localhost          = true
  c.default_cassette_options  = { :record => :new_episodes }
  c.allow_http_connections_when_no_cassette = false
end
