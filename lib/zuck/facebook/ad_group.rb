require 'zuck/facebook/ad_creative'

module Zuck
  class AdGroup < RawFbObject

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :account_id,
               :ad_id,
               :adgroup_id,
               :adgroup_status,
               :bid_type,
               :campaign_id,
               :conversion_specs,
               :created_time,
               :creative_ids,
               :id,
               :disapprove_reason_descriptions,
               :last_updated_by_app_id,
               :max_bid,
               :name,
               :targeting,
               :tracking_specs,
               :updated_time,
               :view_tags

    parent_object :ad_campaign
    list_path     :adgroups
    connections   :ad_creatives

    def self.create(graph, data, ad_campaign)
      path = ad_campaign.ad_account.path
      data['campaign_id'] = ad_campaign.id
      super(graph, data, ad_campaign, path)
    end

  end
end
