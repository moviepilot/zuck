# An ad creative object is an instance of a specific creative which is being
# used to define the creative field of one or more ads.
#
# Usage:
# Zuck::AdCreative.all
# ad_created = Zuck::AdCreative.find('6060102370457')

module Zuck
  class AdCreative < RawFbObject

    FIELDS = %i( id name object_story_id object_story_spec object_type thumbnail_url run_status )

    # https://developers.facebook.com/docs/marketing-api/reference/ad-creative
    known_keys *FIELDS

    list_path :adcreatives

    # https://developers.facebook.com/docs/marketing-api/guides/carousel-ads/v2.6
    def self.carousel(name:, page_id:, link:, message:, assets:, type:, multi_share_optimized:, multi_share_end_card:)
      object_story_spec = {
        'page_id' => page_id, # 300664329976860
        'link_data' => {
          'link' => link, # https://tophatter.com/, https://itunes.apple.com/app/id619460348
          'message' => message,
          'child_attachments' => assets.collect { |asset|
            {
              'link' => link,
              'image_hash' => asset[:hash],
              'call_to_action' => {
                'type' => type, # SHOP_NOW, INSTALL_MOBILE_APP
                'value' => { 'link_title' => asset[:title] } # 'app_link' => 'DEEP LINK'
              }
            }
          },
          'multi_share_optimized' => multi_share_optimized,
          'multi_share_end_card' => multi_share_end_card
        },
      }
      {
        name: name,
        object_story_spec: object_story_spec.to_json
      }
    end

  end
end
