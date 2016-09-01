module Zuck
  class Campaign < Base

    # https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group
    FIELDS = %w(id account_id buying_type can_use_spend_cap configured_status created_time effective_status name objective start_time stop_time updated_time spend_cap)
    attr_accessor *FIELDS
    attr_accessor :ad_account

    # belongs_to

    def ad_account
      @ad_account ||= Zuck::AdAccount.find(account_id)
    end

    # has_many

    def ad_sets(effective_status: ['ACTIVE'])
      response = rest_get("#{id}/adsets", query: Zuck::AdSet.default_query.merge(effective_status: effective_status).compact)
      data     = Zuck::AdSet.paginate(response)
      data.present? ? data.map { |hash| Zuck::AdSet.new(hash.merge(campaign: self)) } : []
    end

    # creation

    def create_ad_set(name:, promoted_object:, targeting:, daily_budget:, billing_event:, optimization_goal:, status:)
      object = rest_post("act_#{account_id}/adsets", query: {
        campaign_id: self.id,
        name: name,
        promoted_object: promoted_object.to_json,
        targeting: targeting.to_json,
        daily_budget: daily_budget,
        billing_event: billing_event,
        optimization_goal: optimization_goal,
        is_autobid: true, # @TODO: Specify bid_amount when possible.
        redownload: false,
        status: status
      })
      raise Exception, object[:error][:error_user_msg] if object[:error].present?
      Zuck::AdSet.new(object)
    end

  end
end
