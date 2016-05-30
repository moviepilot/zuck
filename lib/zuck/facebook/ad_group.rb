require 'zuck/facebook/ad_creative'

module Zuck
  class AdGroup < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/reference/ads-api/adgroup/v2.2)
    known_keys :id,
               :account_id,
               :ad_review_feedback,
               :status,
               :bid_amount,
               :campaign_id,
               :adset_id,
               :created_time,
               :creative,
               :failed_delivery_checks,
               :name,
               :targeting,
               :tracking_specs,
               :updated_time

    parent_object :ad_campaign
    list_path     :ads
    connections   :ad_creatives

    def self.create(graph, data, ad_set)
      path = ad_set.ad_account.path
      data['adset_id'] = ad_set.id
      super(graph, data, ad_set, path)
    end

  end
end
