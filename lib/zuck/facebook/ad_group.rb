require 'zuck/facebook/ad_creative'

module Zuck
  class AdGroup < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/reference/ads-api/adgroup/v2.2)
    known_keys :id,
               :account_id,
               :adgroup_status,
               :bid_type,
               :bid_info,
               :conversion_specs,
               :campaign_id,
               :campaign_group_id,
               :conversion_specs,
               :created_time,
               :creative_ids,
               :failed_delivery_checks,
               :name,
               :targeting,
               :tracking_specs,
               :updated_time,
               :view_tags

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
