# An ad creative object is an instance of a specific creative which is being
# used to define the creative field of one or more ads.
#
# Usage:
# Zuck::AdCreative.all
# ad_created = Zuck::AdCreative.find('6060102370457')

module Zuck
  class AdCreative < RawFbObject

    # https://developers.facebook.com/docs/marketing-api/reference/ad-creative
    FIELDS = %i(id name object_story_id object_story_spec object_type thumbnail_url run_status)

    known_keys *FIELDS

    list_path :adcreatives

    def self.find(id)
      object = rest_get(id, query: { fields: FIELDS.join(',') })
      Zuck::AdCreative.new(Zuck.graph, object, nil)
    end

    def self.photo(name:, page_id:, instagram_actor_id:, message:, link:, link_title:, image_hash:, type:)
      object_story_spec = {
        'page_id' => page_id, # 300664329976860
        'instagram_actor_id' => instagram_actor_id, # 503391023081924
        'link_data' => {
          'link' => link, # https://tophatter.com/, https://itunes.apple.com/app/id619460348
          'message' => message,
          'image_hash' => image_hash,
          'call_to_action' => {
            'type' => type, # SHOP_NOW, INSTALL_MOBILE_APP
            'value' => {
              # 'application' =>,
              'link' => link,
              'link_title' => link_title
            }
          }
        }
      }
      {
        name: name,
        object_story_spec: object_story_spec.to_json
      }
    end

    # https://developers.facebook.com/docs/marketing-api/guides/carousel-ads/v2.6
    def self.carousel(name:, page_id:, instagram_actor_id:, link:, message:, assets:, type:, multi_share_optimized:, multi_share_end_card:)
      object_story_spec = {
        'page_id' => page_id, # 300664329976860
        'instagram_actor_id' => instagram_actor_id, # 503391023081924
        'link_data' => {
          'link' => link, # https://tophatter.com/, https://itunes.apple.com/app/id619460348
          'message' => message,
          'call_to_action' => { 'type' => type }, # SHOP_NOW, INSTALL_MOBILE_APP
          'child_attachments' => assets.collect { |asset|
            {
              'link' => link,
              'image_hash' => asset[:hash],
              'name' => asset[:title],
              # 'description' => asset[:title],
              'call_to_action' => { 'type' => type }
            }
          },
          'multi_share_optimized' => multi_share_optimized,
          'multi_share_end_card' => multi_share_end_card
        }
      }
      {
        name: name,
        object_story_spec: object_story_spec.to_json
      }
    end

  end
end
