# @USAGE:

module Zuck
  class AdSetInsight < RawFbObject

    # https://developers.facebook.com/docs/marketing-api/insights/fields/v2.6
    known_keys :adset_id,
               :date_start,
               :date_stop,
               :impressions,
               :spend

    list_path :insights

    parent_object :ad_set

  end
end
