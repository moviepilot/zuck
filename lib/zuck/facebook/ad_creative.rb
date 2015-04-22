module Zuck
  class AdCreative < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    known_keys :actor_id,
               :body,
               :call_to_action_type,
               :image_crops,
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
