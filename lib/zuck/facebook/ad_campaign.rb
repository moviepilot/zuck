module Zuck
  class AdCampaign < RawFbObject

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :account_id,
               :campaign_id,
               :campaign_status,
               :created_time,
               :daily_imps,
               :end_time,
               :id,
               :lifetime_budget,
               :name,
               :start_time,
               :updated_time

    parent_object :ad_account
    list_path     :adcampaigns
    connections   :ad_groups

  end
end
