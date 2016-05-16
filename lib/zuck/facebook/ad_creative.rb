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
    def self.carousel(name:, page_id:, app_store_url:, message:, assets:, multi_share_optimized: true)
      object_story_spec = {
        'page_id' => page_id,
        'link_data' => {
          'link' => app_store_url,
          'message' => message,
          'child_attachments' => assets.collect { |asset|
            {
              'link' => app_store_url,
              'image_hash' => asset[:hash],
              'call_to_action' => {
                'type' => 'INSTALL_MOBILE_APP', # 'USE_MOBILE_APP'
                'value' => { 'link_title' => asset[:title] } # 'app_link' => 'DEEP LINK'
              }
            }
          },
          'multi_share_optimized' => multi_share_optimized
        },
      }
      {
        name: name,
        object_story_spec: object_story_spec.to_json
      }
    end

  end
end
