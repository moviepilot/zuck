require 'active_support/all'
Dir[File.expand_path("../zuck/util/**/*.rb", __FILE__)].each{ |f| require f}
Dir[File.expand_path("../zuck/koala/**/*.rb", __FILE__)].each{ |f| require f}
Dir[File.expand_path("../zuck/facebook/**/*.rb", __FILE__)].each{ |f| require f}

module Zuck
  extend Koala::Methods
end
