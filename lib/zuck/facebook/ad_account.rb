# An ad account is an account used to manage ads on Facebook. Each ad account
# can be managed by multiple people, and each person can have one or more
# different levels of access to an account, configured by specifying roles for
# each user.
#
# Usage:
# Zuck::AdAccount.all
# account = Zuck::AdAccount.find('39788579')
# account.campaigns
# account.ad_sets
# account.ads

module Zuck
  class AdAccount < RawFbObject
    include Zuck::Helpers

    # Known keys as per
    # [fb docs](https://developers.facebook.com/docs/marketing-api/reference/ad-account)
    known_keys :id,
               :account_groups,
               :account_id,
               :account_status,
               :age,
               :agency_client_declaration,
               :business_city,
               :business_country_code,
               :business_name,
               :business_state,
               :business_street,
               :business_street2,
               :business_zip,
               :capabilities,
               :created_time,
               :currency,
               :disable_reason,
               :end_advertiser,
               :end_advertiser_name,
               :failed_delivery_checks,
               :funding_source,
               :funding_source_details,
               :has_migrated_permissions,
               :io_number,
               :is_notifications_enabled,
               :is_personal,
               :is_prepay_account,
               :is_tax_id_required,
               :line_numbers,
               :media_agency,
               :min_campaign_group_spend_cap,
               :min_daily_budget,
               :name,
               :owner,
               :offsite_pixels_tos_accepted,
               :partner,
               :tax_id,
               :tax_id_status,
               :tax_id_type,
               :timezone_id,
               :timezone_name,
               :timezone_offset_hours_utc,
               :rf_spec,
               :tos_accepted,
               :user_role,
               :vertical_name,
               :amount_spent,
               :spend_cap,
               :balance,
               :business,
               :owner_business,
               :last_used_time,
               :asset_score

    list_path 'me/adaccounts'

    connections :campaigns, :ad_sets, :ads

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
