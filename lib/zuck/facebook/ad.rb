# An ad object contains the data necessary to visually display an ad and
# associate it with a corresponding ad set.
#
# Usage:
# Zuck::Ad.find('6028425575295').ad_account
# Zuck::Ad.find('6028425575295').campaign
# Zuck::Ad.find('6028425575295').ad_set

module Zuck
  class Ad < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/marketing-api/reference/adgroup)
    known_keys :id,
               :account_id,
               :adset,
               :campaign,
               :adlabels,
               :adset_id,
               :bid_amount,
               :bid_info,
               :bid_type,
               :configured_status,
               :conversion_specs,
               :created_time,
               :creative,
               :effective_status,
               :last_updated_by_app_id,
               :name,
               :tracking_specs,
               :updated_time,
               :campaign_id,
               :ad_review_feedback

    list_path :ads

    parent_object :ad_account, as: :account_id
    parent_object :campaign, as: :campaign_id
    parent_object :ad_set, as: :adset_id

    def self.create(graph, data, ad_set)
      path = ad_set.ad_account.path
      data['campaign_id'] = ad_set.id
      super(graph, data, ad_set, path)
    end

  end
end
