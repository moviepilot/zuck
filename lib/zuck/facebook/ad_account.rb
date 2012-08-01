require_relative 'fb_object'

module Zuck
  class AdAccount < FbObject

    # These are taken from https://developers.facebook.com/docs/reference/ads-api/adaccount/
    # the API actually returns more
    known_keys  :account_id,
                :name,
                :account_status,
                :daily_spend_limit,
                :users,
                :currency,
                :timezone_id,
                :timezone_name,
                :capabilities,
                :account_groups,
                :is_personal,
                :business_name,
                :business_street,
                :business_street2,
                :business_city,
                :business_state,
                :business_zip,
                :business_country_code,
                :vat_status,
                :agency_client_declaration
#    connections :ad_campaigns
    list_path   'me/adaccounts'

    # This looks a little funkier than {Zuck::FbObject#path} made
    # you believe. This is because the {AdAccount} has no real parent object.
    def path
      "act_#{self.account_id}"
    end

    def campaigns
      AdCampaign.all(graph, self)
    end

    def self.all
      super(Zuck.graph)
    end
  end
end
