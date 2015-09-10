require 'zuck/facebook/ad_creative'

module Zuck
  class AdSet < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/reference/ads-api/adset/v2.2)
    known_keys :id,
               :name,
               :account_id,
               :bid_amount,
               :bid_info,
               :campaign_group_id,
               :campaign_status,
               :start_time,
               :end_time,
               :updated_time,
               :created_time,
               :daily_budget,
               :lifetime_budget,
               :budget_remaining,
               :targeting,
               :promoted_object

    parent_object :ad_account, as: :account_id
    list_path     :adcampaigns # Yes, this is correct, "for legacy reasons"
    connections   :ad_groups, :ad_creatives

  end
end
