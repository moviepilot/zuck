module Zuck
  class AdAccount < RawFbObject

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :account_id,
               :account_status,
               :balance,
               :business_city,
               :business_country_code,
               :business_name,
               :business_state,
               :business_street,
               :business_street2,
               :business_zip,
               :capabilities,
               :currency,
               :daily_spend_limit,
               :id,
               :is_personal,
               :moo_default_bid,
               :moo_default_conversion_bid,
               :name,
               :notification_settings,
               :timezone_id,
               :timezone_name,
               :timezone_offset_hours_utc,
               :users,
               :vat_status


    list_path   'me/adaccounts'
    connections :ad_campaigns

    def self.all(graph = Zuck.graph)
      super(graph)
    end
  end
end
