require 'active_support/all'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'zuck/koala/koala_methods'
require 'zuck/fb_object'
Dir[File.expand_path("../zuck/facebook/**/*.rb", __FILE__)].each{ |f| require f}

module Zuck
  extend KoalaMethods
end
