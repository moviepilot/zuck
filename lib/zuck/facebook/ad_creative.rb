require_relative 'ad_group'

module Zuck
  class AdCreative < FbObject

    parent_object :ad_group
    list_path     :adcreatives
  end
end
