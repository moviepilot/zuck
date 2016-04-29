# @USAGE:
# Zuck::AdAccount.all
# ad_account = Zuck::AdAccount.find('1051938118182807')
# ad_account.class
# ad_account.campaigns.first.class
# ad_account.ad_sets.first.class
# ad_account.ads.first.class
# ad_account.ad_creatives.first.class
# ad_account.ad_images.first.class

module Zuck
  class AdAccount < RawFbObject
    include Zuck::Helpers

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/marketing-api/reference/ad-account)
    known_keys :id,
               :account_id,
               :account_status,
               :age,
               :created_time,
               :currency,
               :funding_source,
               :funding_source_details,
               :min_campaign_group_spend_cap,
               :min_daily_budget,
               :name,
               :amount_spent,
               :spend_cap,
               :balance,
               :last_used_time

    list_path 'me/adaccounts'

    connections :campaigns, :ad_sets, :ads, :ad_creatives, :ad_images

    def self.all(graph = Zuck.graph)
      super(graph)
    end

    def path
      normalize_account_id(id)
    end

    def set_data(data)
      super
      self.id = normalize_account_id(id)
    end

    # @USAGE:
    # Zuck::AdAccount.find('1051938118182807').get_ad_image('f8966cf7910931fe427cfe38b2a2ec41')
    def get_ad_image(hash)
      get_ad_images([hash]).first
    end

    # @USAGE:
    # Zuck::AdAccount.find('1051938118182807').get_ad_images(['f8966cf7910931fe427cfe38b2a2ec41'])
    def get_ad_images(hashes)
      collection = rest_get("#{id}/adimages", query: { hashes: hashes })

      Koala::Facebook::API::GraphCollection.new(collection, graph).map do |object|
        Zuck::AdImage.new(graph, object, nil)
      end
    end

  end
end
