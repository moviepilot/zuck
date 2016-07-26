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

    # https://developers.facebook.com/docs/marketing-api/reference/ad-account
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

    def path
      normalize_account_id(id)
    end

    def set_data(data)
      super
      self.id = normalize_account_id(id)
    end

    # IMAGES ###################################################################

    # @USAGE:
    # Zuck::AdAccount.find('1051938118182807').get_ad_image('f8966cf7910931fe427cfe38b2a2ec41')
    def get_ad_image(hash)
      get_ad_images([hash]).first
    end

    # @USAGE:
    # Zuck::AdAccount.find('1051938118182807').get_ad_images(['f8966cf7910931fe427cfe38b2a2ec41'])
    def get_ad_images(hashes)
      collection = rest_get("#{id}/adimages", query: {
        hashes: hashes,
        fields: 'hash,name,permalink_url,original_width,original_height'
      })

      Koala::Facebook::API::GraphCollection.new(collection, graph).map do |object|
        Zuck::AdImage.new(graph, object, nil)
      end
    end

    # @USAGE:
    # Zuck::AdAccount.find('1051938118182807').create_ad_image('https://d38eepresuu519.cloudfront.net/fd1d1c521595e95391e47a18efd96c3a/original.jpg')
    def create_ad_image(url)
      create_ad_images([url]).first
    end

    # @USAGE:
    # Zuck::AdAccount.find('1051938118182807').create_ad_images(['https://d38eepresuu519.cloudfront.net/fd1d1c521595e95391e47a18efd96c3a/original.jpg', 'https://d38eepresuu519.cloudfront.net/d6f70e9dcf5c3786523f33dcf03228fe/original.jpg'])
    def create_ad_images(urls)
      files = urls.collect do |url|
        pathname = Pathname.new(url)
        name = "#{pathname.dirname.basename}.jpg"
        data = HTTParty.get(url, timeout: 120).body
        f = File.open("/tmp/#{name}", 'w') # This assumes a *nix-based system.
        f.binmode
        f.write(data)
        f.close
        [name, File.open(f.path)]
      end.to_h

      response = rest_upload("#{id}/adimages", query: files)
      files.values.each { |file| File.delete(file.path) } # Do we really need to do this?
      hashes = response['images'].map { |key, hash| hash['hash'] }
      get_ad_images(hashes)
    end

    # CREATIVES ################################################################

    # @USAGE:
    # creatives = {
    #   name: 'Creative #1',
    #   page_id: '300664329976860',
    #   instagram_actor_id: '503391023081924',
    #   app_store_url: 'http://play.google.com/store/apps/details?id=com.tophatter',
    #   message: 'A message.',
    #   assets: [{ hash: 'f8966cf7910931fe427cfe38b2a2ec41', title: '83% Off' }, ...],
    #   multi_share_optimized: false,
    #   multi_share_end_card: false
    # }
    # Zuck::AdAccount.find('1051938118182807').create_ad_creative(creative)
    def create_ad_creative(creative, carousel: true)
      query = if carousel
        Zuck::AdCreative.carousel(
          name: creative[:name],
          page_id: creative[:page_id],
          instagram_actor_id: creative[:instagram_actor_id],
          link: creative[:link],
          message: creative[:message],
          assets: creative[:assets],
          type: creative[:type],
          multi_share_optimized: creative[:multi_share_optimized],
          multi_share_end_card: creative[:multi_share_end_card]
        )
      else
        Zuck::AdCreative.photo(
          name: creative[:name],
          page_id: creative[:page_id],
          instagram_actor_id: creative[:instagram_actor_id],
          message: creative[:message],
          link: creative[:link],
          link_title: creative[:link_title],
          image_hash: creative[:image_hash],
          type: creative[:type]
        )
      end
      object = rest_post("#{id}/adcreatives", query: query)
      Zuck::AdCreative.new(graph, object, nil)
    end

    # CAMPAIGNS ################################################################

    # @USAGE:
    # Zuck::AdAccount.find('1051938118182807').create_campaign(name: 'Test', objective: 'MOBILE_APP_INSTALLS', status: 'ACTIVE')
    def create_campaign(name:, objective:, status:)
      object = rest_post("#{id}/campaigns", query: {
        name: name,
        objective: objective,
        status: status
      })
      Zuck::Campaign.new(graph, object, nil)
    end

    # AUDIENCES ################################################################

    # @USAGE:
    # audience = Zuck::AdAccount.find('1051938118182807').create_custom_audience(name: 'Test', description: 'This is a test audience.')
    def create_custom_audience(name:, description:)
      object = rest_post("#{id}/customaudiences", query: {
        name: name,
        subtype: 'CUSTOM',
        description: description
      })
      Zuck::CustomAudience.new(graph, object, nil)
    end

    # INSIGHTS #################################################################

    # @USAGE:
    # Zuck::AdAccount.find('1051938118182807').get_insights(Date.today..Date.today)
    def get_insights(range = Date.today..Date.today)
      campaigns = Zuck::AdInsight.get(graph_object_id: id, range: range, level: :campaign, fields: %w(campaign_id))
      campaigns.map do |campaign|
        Zuck::AdInsight.get(graph_object_id: campaign['campaign_id'], range: range)
      end.flatten
    end

    private

    # Facebook returns 'account_ids' without the 'act_' prefix,
    # so we have to treat account_ids special and make sure they
    # begin with act_
    def normalize_account_id(id)
      return id if id.to_s.start_with?('act_')
      "act_#{id}"
    end

  end
end
