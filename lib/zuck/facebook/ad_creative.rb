module Zuck
  class AdCreative < RawFbObject

    # Can't create this directly (yet)
    read_only

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :name,
               :type,
               :object_id,
               :body,
               :image_hash,
               :image_url,
               :id,
               :title,
               :link_url,
               :url_tags,
               :preview_url,
               :related_fan_page,
               :follow_redirect,
               :auto_update,
               :story_id,
               :action_spec

    parent_object :ad_group
    list_path     :adcreatives

  end
end
