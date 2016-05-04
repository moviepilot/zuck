# @USAGE:

module Zuck
  class AdInsight < RawFbObject

    # https://developers.facebook.com/docs/marketing-api/insights/fields/v2.6
    known_keys :ad_id,
               :ad_name,
               :clicks,
               :cost_per_action_type,
               :cost_per_total_action,
               :cost_per_unique_action_type,
               :cost_per_unique_click,
               :cpc,
               :cpm,
               :cpp

    list_path :insights

    parent_object :ad

  end
end
