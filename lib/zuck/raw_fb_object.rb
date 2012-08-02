
Dir[File.expand_path("../koala/**/*.rb", __FILE__)].each{ |f| require f}
Dir[File.expand_path("../fb_object/**/*.rb", __FILE__)].each{ |f| require f}

module Zuck
  module FbObject
    # An object that includes {Zuck::HashDelegator} for easy hash
    # access and default keys as methods as well as the `graph`
    # getter and setter from {Zuck::Koala::Methods}.
    #
    # By inheriting from this object, each fb object gets implemented
    # automatically (tm) through calling a couple of DSL methods and
    # defining how an object can obtain its own path.
    #
    # I feel it is example time, here's an imaginary ad campaign:
    #
    #     class AdCampaign < FbObject
    #
    #       known_keys    :title, :budget
    #       parent_object :ad_account
    #       list_path     :adcampaigns
    #
    #     end
    #
    # These handy things are now provided by {FbObject} to your object:
    #
    # 1.  Each `AdCampaign` object has a `title` and `budget` method. In
    #     case facebook returned more information than what's documented
    #     (there are a lot of these), you can still call
    #     `my_campaign[:secret_key]` to get to the juicy bits
    # 2.  You can call `AdCampaign.all(graph, my_ad_account)`, because your
    #     `AdCampaign` instance knows how to construct the path
    #     `act_12345/adcampaigns`. It knows this, because it knows its
    #     parent object and its own list path.
    #
    class RawFbObject
      include Zuck::HashDelegator
      include Zuck::KoalaMethods
      include Zuck::FbObject::DSL
      include Zuck::FbObject::Read

    end
  end
end
