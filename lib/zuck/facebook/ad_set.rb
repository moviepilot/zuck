# @USAGE:
# Zuck::AdSet.all
# ad_set = Zuck::AdSet.find('6060101424057')
# ad_set.class
# ad_set.campaign.class
# ad_set.ads.first.class
# ad_set.ad_creatives.first.class

module Zuck
  class AdSet < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign)
    known_keys :adlabels,
               :adset_schedule,
               :id,
               :account_id,
               :bid_amount,
               :bid_info,
               :billing_event,
               :campaign,
               :campaign_id,
               :configured_status,
               :created_time,
               :creative_sequence,
               :effective_status,
               :end_time,
               :frequency_cap,
               :frequency_cap_reset_period,
               :frequency_control_specs,
               :is_autobid,
               :lifetime_frequency_cap,
               :lifetime_imps,
               :name,
               :optimization_goal,
               :promoted_object,
               :rf_prediction_id,
               :rtb_flag,
               :start_time,
               :targeting,
               :updated_time,
               :use_new_app_click,
               :pacing_type,
               :budget_remaining,
               :daily_budget,
               :lifetime_budget

    list_path :adsets

    parent_object :campaign, as: :campaign_id
    parent_object :ad_account, as: :account_id

    connections :ads, :ad_creatives

    # @USAGE:
    # ad_set = Zuck::AdSet.find('6060101424057')
    # ad = ad_set.create_android_carousel_ad(
    #   name: 'tops',
    #   message: 'Lowest Prices + Free Shipping on select items.',
    #   assets: [
    #     { hash: 'f8966cf7910931fe427cfe38b2a2ec41', title: '83% Off' },
    #     { hash: 'e20e7d70e7808674155b0a387c604cee', title: '81% Off' },
    #     { hash: '5a149de42b8296ad92ce2d3ace35008c', title: 'Free Shipping' }
    #   ]
    # )
    def create_android_carousel_ad(name:, message:, assets:)
      ad_creative = create_ad_creative(app_store_url: 'http://play.google.com/store/apps/details?id=com.tophatter', message: message, assets: assets)
      create_ad("name=#{name}&platform=ios&type=carousel", ad_creative.id)
    end

    # @USAGE:
    # ad_set = Zuck::AdSet.find('6060102415657')
    # ad = ad_set.create_ios_carousel_ad(
    #   name: 'tops',
    #   message: 'Lowest Prices + Free Shipping on select items.',
    #   assets: [
    #     { hash: 'f8966cf7910931fe427cfe38b2a2ec41', title: '83% Off' },
    #     { hash: 'e20e7d70e7808674155b0a387c604cee', title: '81% Off' },
    #     { hash: '5a149de42b8296ad92ce2d3ace35008c', title: 'Free Shipping' }
    #   ]
    # )
    def create_ios_carousel_ad(name:, message:, assets:)
      ad_creative = create_ad_creative(app_store_url: 'https://itunes.apple.com/app/id619460348', message: message, assets: assets)
      create_ad("name=#{name}&platform=android&type=carousel", ad_creative.id)
    end

    def create_web_carousel_ad(name:, message:, assets:)
      # @TODO
    end

    def create_android_image_ad(name:, message:, assets:)
      # @TODO
    end

    def create_ios_image_ad(name:, message:, assets:)
      # @TODO
    end

    def create_web_image_ad(name:, message:, assets:)
      # @TODO
    end

    private

    def create_ad_creative(type: 'carousel', page_id: '300664329976860', app_store_url:, message:, assets:)
      data = case type
      when 'carousel'
        Zuck::AdCreative.carousel(
          page_id: page_id,
          app_store_url: app_store_url,
          message: message,
          assets: assets
        )
      else
        raise Exception, "Unhandled ad creative type: #{type}"
      end

      Zuck::AdCreative.create(graph, data, nil, "act_#{account_id}")
    end

    def create_ad(name, creative_id)
      rest_post("act_#{account_id}/ads", query: {
        name: name,
        adset_id: id,
        creative: { creative_id: creative_id }.to_json }
      )
    end

  end
end
