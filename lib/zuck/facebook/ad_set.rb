# An ad set is a group of ads that share the same daily or lifetime budget,
# schedule, bid type, bid info, and targeting data. Ad sets enable you to group
# ads according to your criteria, and you can retrieve the ad-related statistics
# that apply to a set.

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
               :product_ad_behavior,
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

    parent_object :ad_account, as: :account_id
    parent_object :campaign, as: :campaign_id

    connections :ads

  end
end
