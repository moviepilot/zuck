require_relative 'fb_object'

module Zuck
  class AdGroup < FbObject

    # These are taken from https://developers.facebook.com/docs/reference/ads-api/adaccount/
    # the API actually returns more
    known_keys :ad_id,
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

    def self.all(graph, campaign)
      r = get(graph, "#{campaign.id}/adgroups")
      r.map do |g|
        new(graph, g, campaign)
      end
    end

  end
end
