module Zuck
  class AdAccount < RawFbObject

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :account_groups,
               :account_id,
               :account_status,
               :age,
               :agency_client_declaration,
               :amount_spent,
               :balance,
               :business_city,
               :business_country_code,
               :business_name,
               :business_state,
               :business_street2,
               :business_street,
               :business_zip,
               :capabilities,
               :currency,
               :daily_spend_limit,
               :id,
               :is_personal,
               :name,
               :spend_cap,
               :timezone_id,
               :timezone_name,
               :timezone_offset_hours_utc,
               :tos_accepted,
               :users


    list_path   'me/adaccounts'
    connections :ad_campaigns,
                :custom_audiences

    def self.all(graph = Zuck.graph)
      super(graph)
    end
  end
end
