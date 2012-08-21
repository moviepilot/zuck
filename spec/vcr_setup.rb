# VCR Config
require 'vcr'
FileUtils.mkdir("log") rescue nil
VCR.configure do |c|
  dir = File.expand_path("../../spec/fixtures", __FILE__)
  c.cassette_library_dir      = dir
  c.hook_into                 :webmock
  c.ignore_localhost          = true
  c.default_cassette_options  = {
    record: :new_episodes,
    match_requests_on: [:method, :body, :uri]
  }
  c.allow_http_connections_when_no_cassette = false
  c.debug_logger = File.open(File.expand_path("../../log/vcr.log", __FILE__), "w")
end
