require 'active_support/all'
Dir[File.expand_path("../**/*.rb", __FILE__)].each do |f|
  require f
end


module Zuck
  extend Koala::Methods
end
