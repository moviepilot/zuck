module Zuck # list_path :adsets
  class AdSet < Base

    # https://developers.facebook.com/docs/marketing-api/reference/ad-set
    FIELDS = %w(id account_id campaign_id adlabels adset_schedule bid_amount bid_info billing_event configured_status created_time creative_sequence effective_status end_time frequency_cap frequency_cap_reset_period frequency_control_specs is_autobid lifetime_frequency_cap lifetime_imps name optimization_goal promoted_object rf_prediction_id rtb_flag start_time targeting updated_time use_new_app_click pacing_type budget_remaining daily_budget lifetime_budget)
    attr_accessor *FIELDS
    attr_accessor :campaign

    # belongs_to

    def campaign
      @campaign ||= Zuck::Campaign.find(campaign_id)
    end

    # has_many

    def ads(effective_status: ['ACTIVE'], limit: 100)
      response = rest_get("#{id}/ads", query: Zuck::Ad.default_query.merge(effective_status: effective_status, limit: limit).compact)
      data     = Zuck::Ad.paginate(response)
      data.present? ? data.map { |hash| Zuck::Ad.new(hash.merge(ad_set: self)) } : []
    end

    # creation

    def create_ad(name:, creative_id:)
      object = rest_post("act_#{account_id}/ads", query: { name: name, adset_id: id, creative: { creative_id: creative_id }.to_json })
      raise Exception, object[:error][:error_user_msg] if object[:error].present?
      Zuck::Ad.new(object)
    end

  end
end
