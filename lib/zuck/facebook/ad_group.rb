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
      p = ad_campaign.ad_account
      path = p.path

      data['campaign_id'] = ad_campaign.path

      # We want facebook to return the data of the created object
      data["redownload"] = 1

      # Create
      result = put(graph, path, list_path, data)["data"]

      # The data is nested by name and id, e.g.
      #
      #     "campaigns" => { "12345" => "data" }
      #
      # Since we only put one at a time, we'll fetch this like that.
      data = result.values.first.values.first

      # Return a new instance
      new(graph, data, ad_campaign)
    end

  end
end
