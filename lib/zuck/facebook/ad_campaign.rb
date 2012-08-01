require_relative 'fb_object'

module Zuck
  class AdCampaign < FbObject

    # These are taken from https://developers.facebook.com/docs/reference/ads-api/adaccount/
    # the API actually returns more
    known_keys :id,
               :account_id,
               :name,
               :start_time,
               :end_time,
               :daily_budget,
               :campaign_status,
               :lifetime_budget

    parent_object :ad_account
    list_path     :adcampaigns

    def groups
      AdGroup.all(graph, self)
    end

  end
end
