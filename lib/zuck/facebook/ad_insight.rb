# @USAGE:

module Zuck
  class AdInsight < RawFbObject

    # https://developers.facebook.com/docs/marketing-api/insights/fields/v2.6
    known_keys :ad_id, :clicks

    list_path :insights

    parent_object :ad

  end
end
