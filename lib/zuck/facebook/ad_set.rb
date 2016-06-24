# @USAGE:
# Zuck::AdSet.all
# ad_set = Zuck::AdSet.find('6060101424057')
# ad_set.class
# ad_set.campaign.class
# ad_set.ads.first.class
# ad_set.ad_creatives.first.class

module Zuck
  class AdSet < RawFbObject

    # https://developers.facebook.com/docs/marketing-api/reference/ad-set
    FIELDS = %i(adlabels adset_schedule id account_id bid_amount bid_info billing_event campaign campaign_id configured_status created_time creative_sequence effective_status end_time frequency_cap frequency_cap_reset_period frequency_control_specs is_autobid lifetime_frequency_cap lifetime_imps name optimization_goal promoted_object rf_prediction_id rtb_flag start_time targeting updated_time use_new_app_click pacing_type budget_remaining daily_budget lifetime_budget)

    known_keys *FIELDS

    list_path :adsets

    parent_object :campaign, as: :campaign_id
    parent_object :ad_account, as: :account_id

    connections :ads, :ad_creatives

    def self.find(id)
      object = rest_get(id, query: { fields: FIELDS.join(',') })
      Zuck::AdSet.new(Zuck.graph, object, nil)
    end

    # @USAGE:
    # Zuck::AdSet.find('6060101424057').create_ad(name: 'tops', creative_id: 12345)
    def create_ad(name:, creative_id:)
      object = rest_post("act_#{account_id}/ads", query: { name: name, adset_id: id, creative: { creative_id: creative_id }.to_json })
      raise Exception, object[:error][:error_user_msg] if object[:error].present?
      Zuck::Ad.new(graph, object, nil)
    end

  end
end
