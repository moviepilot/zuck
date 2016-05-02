# @USAGE:
# image = Zuck::AdImage.all.first
# image.id
# image.ad_account

module Zuck
  class AdImage < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/marketing-api/reference/ad-image)
    known_keys :id,
               :hash,
               :name,
               :permalink_url,
               :original_width,
               :original_height

    list_path :adimages

    parent_object :ad_account, as: :account_id

  end
end
