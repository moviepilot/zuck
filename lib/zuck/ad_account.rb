module Zuck
  class AdAccount < Base

    # https://developers.facebook.com/docs/marketing-api/reference/ad-account
    FIELDS = %w(id account_id account_status age created_time currency min_campaign_group_spend_cap min_daily_budget name amount_spent spend_cap balance last_used_time)
    attr_accessor *FIELDS

    class << self
      # accounts = Zuck::AdAccount.all
      def all
        response = rest_get('me/adaccounts', query: default_query)
        response.key?('data') ? response['data'].map { |hash| new(hash) } : []
      end

      # account = Zuck::AdAccount.find_by(name: 'Web')
      def find_by(conditions)
        all.detect do |ad_account|
          conditions.all? do |key, value|
            ad_account.send(key) == value
          end
        end
      end
    end

    # has_many

    def campaigns(effective_status: ['ACTIVE'], limit: 100)
      response = rest_get("#{id}/campaigns", query: Zuck::Campaign.default_query.merge(effective_status: effective_status, limit: limit).compact)
      data     = Zuck::Campaign.paginate(response)
      data.present? ? data.map { |hash| Zuck::Campaign.new(hash.merge(ad_account: self)) } : []
    end

    def ad_creatives(limit: 100)
      response = rest_get("#{id}/adcreatives", query: Zuck::AdCreative.default_query.merge(limit: limit).compact)
      data     = Zuck::AdCreative.paginate(response)
      data.present? ? data.map { |hash| Zuck::AdCreative.new(hash.merge(ad_account: self)) } : []
    end

    def ad_images(hashes: nil, limit: 100)
      response = rest_get("#{id}/adimages", query: Zuck::AdImage.default_query.merge(hashes: hashes, limit: limit).compact)
      data     = Zuck::AdImage.paginate(response)
      data.present? ? data.map { |hash| Zuck::AdImage.new(hash.merge(ad_account: self)) } : []
    end

    # @TODO: Move to Zuck::Campaign.
    def get_insights(range = Date.today..Date.today)
      campaigns = Zuck::AdInsight.get(graph_object_id: id, range: range, level: :campaign, fields: %w(campaign_id))
      campaigns.map do |campaign|
        Zuck::AdInsight.get(graph_object_id: campaign['campaign_id'], range: range)
      end.flatten
    end

    # IMAGE CREATION ###########################################################

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

      if response['images'].present?
        hashes = response['images'].map { |key, hash| hash['hash'] }
        ad_images(hashes: hashes)
      else
        puts response.inspect # Need real error handling.
        []
      end
    end

    # CREATIVE CREATION ########################################################

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
      Zuck::AdCreative.new(object)
    end

    # CAMPAIGN CREATION ########################################################

    # @USAGE:
    # Zuck::AdAccount.find('1051938118182807').create_campaign(name: 'Test', objective: 'MOBILE_APP_INSTALLS', status: 'ACTIVE')
    def create_campaign(name:, objective:, status:)
      object = rest_post("#{id}/campaigns", query: {
        name: name,
        objective: objective,
        status: status
      })
      Zuck::Campaign.new(object)
    end

  end
end
