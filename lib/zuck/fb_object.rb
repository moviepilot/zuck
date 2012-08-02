Dir[File.expand_path("../koala/**/*.rb", __FILE__)].each{ |f| require f}
Dir[File.expand_path("../fb_object/**/*.rb", __FILE__)].each{ |f| require f}
require 'zuck/raw_fb_object'

Zuck::RawFbObject = Zuck::FbObject::RawFbObject
