module Zuck
  class CustomAudience < RawFbObject

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :id,
               :name,
               :type,
               :subtype,
               :rule,
               :description,
               :opt_out_link,
               :retention_days


    parent_object :ad_account
    list_path     :customaudiences

  end
end
