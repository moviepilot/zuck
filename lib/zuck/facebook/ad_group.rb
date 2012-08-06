require 'zuck/facebook/ad_creative'

module Zuck
  class AdGroup < RawFbObject

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :account_id,
               :ad_id,
               :ad_status,
               :adgroup_id,
               :adgroup_status,
               :bid_info,
               :bid_type,
               :campaign_id,
               :conversion_specs,
               :created_time,
               :creative_ids,
               :end_time,
               :id,
               :max_bid,
               :name,
               :start_time,
               :targeting,
               :updated_time

    parent_object :ad_campaign
    list_path     :adgroups
    connections   :ad_creatives

    def self.create(graph, data, ad_campaign = nil)
      path = ad_campaign.ad_account.path
      super(graph, data, ad_campaign, path)
    end

  end
end
