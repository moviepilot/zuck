# External requires.
require 'active_support/all'
require 'koala'
require 'httparty'
require 'httmultiparty'

# Internal requires.
require 'zuck/koala/koala_methods'
Dir[File.expand_path('../zuck/fb_object/**/*.rb', __FILE__)].each { |f| require f }
require 'zuck/fb_object'
Zuck::RawFbObject = Zuck::FbObject::RawFbObject
Dir[File.expand_path('../zuck/facebook/**/*.rb', __FILE__)].each { |f| require f }

Koala.config.api_version = 'v2.7'

module Zuck
  extend KoalaMethods
end
