# @USAGE:
# image = Zuck::AdImage.all.first
# image.id
# image.ad_account

module Zuck
  class AdImage < RawFbObject
    include Zuck::Helpers

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/marketing-api/reference/ad-image)
    known_keys :id,
               :hash

    list_path :adimages

    parent_object :ad_account, as: :account_id

  end
end
