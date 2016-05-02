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
      collection = rest_get("#{id}/adimages", query: {
        hashes: hashes,
        fields: 'hash,name,permalink_url,original_width,original_height'
      })

      Koala::Facebook::API::GraphCollection.new(collection, graph).map do |object|
        Zuck::AdImage.new(graph, object, nil)
      end
    end

    # @USAGE:
    # Zuck::AdAccount.find('1051938118182807').create_ad_creative(
    #   name: 'tops',
    #   page_id: '300664329976860',
    #   app_store_url: 'http://play.google.com/store/apps/details?id=com.tophatter',
    #   message: 'Lowest Prices + Free Shipping on select items.',
    #   assets: [
    #     { hash: 'f8966cf7910931fe427cfe38b2a2ec41', title: '83% Off' },
    #     { hash: 'e20e7d70e7808674155b0a387c604cee', title: '81% Off' },
    #     { hash: '5a149de42b8296ad92ce2d3ace35008c', title: 'Free Shipping' }
    #   ]
    # )
    def create_ad_creative(name:, page_id:, app_store_url:, message:, assets:, type: 'carousel')
      object = case type
      when 'carousel' then Zuck::AdCreative.carousel(name: name, page_id: page_id, app_store_url: app_store_url, message: message, assets: assets)
      else raise Exception, "Unhandled ad creative type: #{type}"
      end

      Zuck::AdCreative.create(graph, object, nil, id)
      # @TODO: Check for errors here.
      # @TODO: Create via a call to rest_post.
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

      files.values.each do |file| # Do we really need to do this?
        File.delete(file.path)
      end

      response['images'].collect do |name, object|
        Zuck::AdImage.new(graph, object, nil)
      end
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
