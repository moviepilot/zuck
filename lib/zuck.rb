require 'active_support/all'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'zuck/koala/koala_methods'
require 'zuck/fb_object'
require 'zuck/helpers'
Dir[File.expand_path("../zuck/facebook/**/*.rb", __FILE__)].each{ |f| require f}

Koala.config.api_version = 'v2.6' if Koala.config.api_version == nil
puts 'Koala Config Version: ' + Koala.config.api_version

if Koala.config.api_version != 'v2.5'
  warn('!!! Zuck was written for Facebook API version v2.5 and may not work!')
  warn("    The current Koala.config.api_version='#{Koala.config.api_version}' does not match 'v2.5'!")
end

module Zuck
  extend KoalaMethods
end
