require_relative 'fb_object'

module Zuck
  class AdAccount < FbObject
  known_keys :id,
             :account_id,
             :name,
             :account_status,
             :currency,
             :timezone_id,
             :timezone_name,
             :timezone_offset_hours_utc,
             :is_personal,
             :business_name,
             :business_street,
             :business_street2,
             :business_city,
             :business_state,
             :business_zip,
             :business_country_code,
             :vat_status,
             :daily_spend_limit,
             :users,
             :notification_settings,
             :capabilities,
             :balance,
             :moo_default_conversion_bid,
             :moo_default_bid

  def self.all(graph = Zuck.graph)
    r = graph.get_object('me/adaccounts')
    r.map do |a|
      new(graph, a)
    end
  end

  def initialize(graph, data)
    self.graph = graph
    set_hash_delegator_data(data)
  end

  end
end
