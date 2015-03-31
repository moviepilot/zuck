module Zuck
  class AdCreative < RawFbObject

    # Can't create this directly (yet)
    # read_only

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    known_keys :actor_id,
               :body,
               :call_to_action_type,
               :follow_redirect,
               :image_crops,
               :image_file,
               :image_hash,
               :image_url,
               :link_url,
               :name,
               :object_id,
               :object_story_id,
               :object_story_spec,
               :object_url,
               :title,
               :url_tags,
               :id

    parent_object :ad_group
    list_path     :adcreatives

  end
end
