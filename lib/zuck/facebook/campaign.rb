# @USAGE:
# Zuck::Campaign.all
# campaign = Zuck::Campaign.find('6060101423257')
# campaign.class
# campaign.ad_account.class
# campaign.ad_sets.first.class
# campaign.ads.first.class

module Zuck
  class Campaign < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group)
    known_keys :id,
               :account_id,
               :buying_type,
               :can_use_spend_cap,
               :configured_status,
               :created_time,
               :effective_status,
               :name,
               :objective,
               :start_time,
               :stop_time,
               :updated_time,
               :spend_cap

    list_path :campaigns

    parent_object :ad_account, as: :account_id

    connections :ad_sets, :ads

  end
end
