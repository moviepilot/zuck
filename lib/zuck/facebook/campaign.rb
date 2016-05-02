# @USAGE:
# Zuck::Campaign.all
# campaign = Zuck::Campaign.find('6060101423257')
# campaign.class
# campaign.ad_account.class
# campaign.ad_sets.first.class
# campaign.ads.first.class

module Zuck
  class Campaign < RawFbObject

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group)
    known_keys :id,
               :account_id,
               :buying_type,
               :can_use_spend_cap,
               :configured_status,
               :created_time,
               :effective_status,
               :name,
               :objective,
               :start_time,
               :stop_time,
               :updated_time,
               :spend_cap

    list_path :campaigns

    parent_object :ad_account, as: :account_id

    connections :ad_sets, :ads

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
        redownload: true,
        status: status
      })
      raise Exception, object[:error][:error_user_msg] if object[:error].present?
      Zuck::AdSet.new(graph, object, nil)
    end

  end
end
