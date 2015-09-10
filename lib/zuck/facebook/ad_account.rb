module Zuck
  class AdAccount < RawFbObject
    include Zuck::Helpers

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
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
               :created_time,
               :currency,
               # :daily_spend_limit,
               :end_advertiser,
               :funding_source,
               :funding_source_details,
               :id,
               :is_personal,
               :media_agency,
               :name,
               :offsite_pixels_tos_accepted,
               :partner,
               :spend_cap,
               :timezone_id,
               :timezone_name,
               :timezone_offset_hours_utc,
               :tos_accepted,
               :users,
               :tax_id_status


    list_path   'me/adaccounts'
    connections :ad_campaigns, :ad_sets, :ad_groups

    def self.all(graph = Zuck.graph)
      super(graph)
    end

    def path
      normalize_account_id(id)
    end

    def set_data(data)
      super
      self.id = normalize_account_id(id)
    end

  end
end
