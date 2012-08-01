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

    def self.all(graph, ad_account)
      r = get(graph, "act_#{ad_account.account_id}/adcampaigns")
      r.map do |c|
        new(graph, c, ad_account)
      end
    end

    def groups
      AdGroup.all(graph, self)
    end

  end
end
