# An ad object contains the data necessary to visually display an ad and
# associate it with a corresponding ad set.
#
# Usage:
# Zuck::Ad.all
# ad = Zuck::Ad.find('6060101427457')
# ad.class
# ad.ad_set.class
# ad.ad_creatives.first.class

module Zuck
  class Ad < RawFbObject

    # https://developers.facebook.com/docs/marketing-api/reference/adgroup
    FIELDS = %i(id account_id adset campaign adlabels adset_id bid_amount bid_info bid_type configured_status conversion_specs created_time creative effective_status last_updated_by_app_id name tracking_specs updated_time campaign_id ad_review_feedback)

    known_keys *FIELDS

    list_path :ads

    parent_object :ad_set, as: :adset_id

    def self.find(id)
      object = rest_get(id, query: { fields: FIELDS.join(',') })
      Zuck::Ad.new(Zuck.graph, object, nil)
    end

    def ad_creative
      @ad_creative ||= Zuck::AdCreative.find(creative['id'])
    end

  end
end
