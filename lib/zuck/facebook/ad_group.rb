require 'zuck/facebook/ad_creative'

module Zuck
  class AdGroup < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/reference/ads-api/adgroup/v2.2)
    known_keys :id,
               :account_id,
               # not available anymore to send, but still there in a response
               # :adgroup_status,
               # :bid_type,
               # :bid_info,
               :conversion_specs,
               :campaign_id,
               :campaign_group_id,
               :created_time,
               :creative_ids,
               :failed_delivery_checks,
               :name,
               :tracking_specs,
               :updated_time
               # app must be whitelisted to use view_tags
               # :view_tags

    parent_object :ad_campaign
    list_path     :adgroups
    connections   :ad_creatives

    def self.create(graph, data, ad_set)
      path = ad_set.ad_account.path
      data['campaign_id'] = ad_set.id
      super(graph, data, ad_set, path)
    end

  end
end
