# @USAGE:
# Zuck::SavedAudience.find(6060590636057)

module Zuck
  class SavedAudience < RawFbObject

    # https://developers.facebook.com/docs/marketing-api/reference/saved-audience
    known_keys :id,
               :account,
               :approximate_count,
               :description,
               :last_used_time,
               :name,
               :owner_business,
               :run_status,
               :sentence_lines,
               :targeting,
               :time_created,
               :time_updated

    parent_object :ad_account, as: :account_id

  end
end
