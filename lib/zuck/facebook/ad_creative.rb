# An ad creative object is an instance of a specific creative which is being
# used to define the creative field of one or more ads.
#
# Usage:
# Zuck::AdCreative.all

# creative = Zuck::AdCreative.create(graph, {
#   'object_story_spec' => Zuck::AdCreative.object_story_spec(
#     page_id: '300664329976860',
#     app_id: '295802707128640',
#     message: 'Shop 70% Off Retail.',
#     link: 'https://itunes.apple.com/us/app/id619460348',
#     assets: {
#       'https://d38eepresuu519.cloudfront.net/b33b5839aab2973e3720a36beec29012/original.jpg?a' => '$1',
#       'https://d38eepresuu519.cloudfront.net/b33b5839aab2973e3720a36beec29012/original.jpg?b' => '$2',
#       'https://d38eepresuu519.cloudfront.net/b33b5839aab2973e3720a36beec29012/original.jpg?c' => '$3',
#       'https://d38eepresuu519.cloudfront.net/b33b5839aab2973e3720a36beec29012/original.jpg?d' => '$4',
#       'https://d38eepresuu519.cloudfront.net/b33b5839aab2973e3720a36beec29012/original.jpg?e' => '$5'
#     }
#   ).to_json
# }, nil, 'act_39788579')

# [:object_story_spec]['link_data']['call_to_action']
# Zuck::AdCreative.find('6033298350770')
# Zuck::AdCreative.find('6036660637895')
# Zuck::AdCreative.find('6036659669695')
# Zuck::AdCreative.find('6036660824895')
# Zuck::AdCreative.find('6036661096495')

module Zuck
  class AdCreative < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/marketing-api/reference/ad-creative)
    known_keys :id,
               :actor_id,
               :adlabels,
               :body,
               :call_to_action_type,
               :image_crops,
               :image_hash,
               :image_url,
               :link_og_id,
               :link_url,
               :name,
               :object_id,
               :object_url,
               :object_story_id,
               :object_story_spec,
               :object_type,
               :platform_customizations,
               :product_set_id,
               :run_status,
               :template_url,
               :thumbnail_url,
               :title,
               :url_tags,
               :applink_treatment

    list_path :adcreatives

    def self.object_story_spec(page_id:, app_id:, message:, link:, assets:)
      {
        'page_id' => page_id,
        'link_data' => {
          'message' => message,
          'link' => link,
          'call_to_action' => {
            'type' => 'INSTALL_MOBILE_APP',
            'value' => {
              'link' => link,
              'link_title' => message
            }
          },
          'child_attachments' => assets.collect { |picture, name|
            {
              'link' => link,
              'picture' => picture,
              'name' => name,
              'call_to_action' => {
                'type' => 'INSTALL_MOBILE_APP',
                'value' => {
                  'application' => app_id,
                  'link' => link,
                  'link_title' => name
                }
              }
            }
          }
        }
      }
    end

  end
end
