module Zuck
  class Ad < Base

    # https://developers.facebook.com/docs/marketing-api/reference/adgroup
    FIELDS = %w(id account_id campaign_id adset_id adlabels bid_amount bid_info bid_type configured_status conversion_specs created_time creative effective_status last_updated_by_app_id name tracking_specs updated_time ad_review_feedback)
    attr_accessor *FIELDS
    attr_accessor :ad_set
    attr_accessor :ad_creative

    # belongs_to

    def ad_set
      @ad_set ||= Zuck::AdSet.find(adset_id)
    end

    def ad_creative
      @ad_creative ||= Zuck::AdCreative.find(creative['id'])
    end

  end
end
