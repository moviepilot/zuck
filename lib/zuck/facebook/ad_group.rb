require 'zuck/facebook/ad_creative'

module Zuck
  class AdGroup < RawFbObject

    # These are taken from https://developers.facebook.com/docs/reference/ads-api/adaccount/
    # the API actually returns more
    known_keys :id,
               :ad_id,
               :campaign_id,
               :name,
               :adgroup_status,
               :bid_type,
               :max_bid,
               :targeting,
               :creative,
               :adgroup_id,
               :end_time,
               :start_time,
               :updated_time,
               :bid_info,
               :disapprove_reason_descriptions,
               :view_tags

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
