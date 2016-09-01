module Zuck # list_path :adimages
  class AdImage < Base

    # https://developers.facebook.com/docs/marketing-api/reference/ad-image
    FIELDS = %w(id hash name permalink_url original_width original_height)
    attr_accessor *FIELDS
    attr_accessor :ad_account

  end
end
