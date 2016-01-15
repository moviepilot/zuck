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
    #     class AdSet < FbObject
    #
    #       known_keys    :title, :budget
    #       list_path     :adsets
    #       connections   :ad_groups
    #       parent_object :ad_account, as: :account_id
    #
    #     end
    #
    # These handy things are now provided by {FbObject} to your object:
    #
    # 1.  Each `AdSet` object has a `title` and `budget` method. In
    #     case facebook returned more information than what's documented
    #     (there are a lot of these), you can still call
    #     `my_campaign[:secret_key]` to get to the juicy bits
    # 2.  You can call `AdSet.all(graph, my_ad_account)`, because your
    #     `AdSet` instance knows how to construct the path
    #     `act_12345/adsets`. It knows this, because it knows its
    #     parent object and its own list path.
    # 3.  You can call `#ad_groups` on any `AdSet` instance to fetch
    #     the ad groups in that campaign. To add an ad_group to a campaign,
    #     you can call `AdGroup.create(graph, data, my_campaign)`, or for
    #     short: `my_campaign.create_ad_group(data)`
    #
    class RawFbObject
      extend  Zuck::FbObject::Helpers
      include Zuck::FbObject::Helpers
      include Zuck::HashDelegator
      include Zuck::KoalaMethods
      include Zuck::FbObject::DSL
      include Zuck::FbObject::Read
      include Zuck::FbObject::Write
    end
  end
end

# See #{Zuck::FbObject::RawFbObject}
Zuck::RawFbObject = Zuck::FbObject::RawFbObject
