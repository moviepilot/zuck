require 'active_support/all'
require 'zuck/koala/koala_methods'
Koala.config.api_version = 'v2.6'
Dir[File.expand_path("../zuck/fb_object/**/*.rb", __FILE__)].each { |f| require f }
require 'zuck/fb_object'
Zuck::RawFbObject = Zuck::FbObject::RawFbObject
Dir[File.expand_path('../zuck/facebook/**/*.rb', __FILE__)].each { |f| require f }

module Zuck
  extend KoalaMethods
end
