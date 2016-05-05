# @USAGE:
# Zuck::CustomAudience.find(6041700608895)

module Zuck
  class CustomAudience < RawFbObject

    # https://developers.facebook.com/docs/marketing-api/reference/custom-audience
    known_keys :id,
               :account_id,
               :approximate_count,
               :data_source,
               :delivery_status,
               :description,
               :excluded_custom_audiences,
               :external_event_source,
               :included_custom_audiences,
               :last_used_time,
               :lookalike_audience_ids,
               :lookalike_spec,
               :name,
               :operation_status,
               :opt_out_link,
               :owner_business,
               :permission_for_actions,
               :pixel_id,
               :retention_days,
               :rule,
               :subtype,
               :time_content_updated,
               :time_created,
               :time_updated

    parent_object :ad_account, as: :account_id

  end
end
