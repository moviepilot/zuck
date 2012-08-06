module Zuck
  class AdCreative < RawFbObject

    # Can't create this directly (yet)
    read_only

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :alt_view_tags,
               :body,
               :count_current_adgroups,
               :creative_id,
               :id,
               :image_hash,
               :image_url,
               :link_url,
               :name,
               :object_id,
               :preview_url,
               :run_status,
               :title,
               :type,
               :view_tag

    parent_object :ad_group
    list_path     :adcreatives

  end
end
