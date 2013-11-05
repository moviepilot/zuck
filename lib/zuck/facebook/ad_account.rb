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
               :users,
               :vat_status


    list_path   'me/adaccounts'
    connections :ad_campaigns, :ad_groups

    def self.all(graph = Zuck.graph)
      super(graph)
    end
    
    # gets AdCampaign stats for this AdAccount
    #
    # @param {Boolean} get_all True if we want to page through all results, false if we only want the first page
    # @param [DateTime] start_time the time we want to get results back from
    # @param [DateTime] end_time the time we want to get results to, inclusive
    # 
    # @return {Array} If we get all results, this will be an array of the data returned from FB. If we only
    #                 get one page of results, this will be a GraphCollection object that has paging support on it
    def adcampaignstats(get_all, start_time = nil, end_time = nil)
      stats_path = path+"/adcampaignstats"+self.class.get_stats_query(start_time, end_time)
      
      result = []
      if get_all
        r = get(graph, stats_path)
        while r.to_a.count > 0
          result.concat(r.to_a)
          r = r.next_page
        end
      else
        result = get(graph, stats_path)
      end
      return result
    end
    
    # gets AdGroup stats for this AdAccount
    #
    # @param {Boolean} get_all True if we want to page through all results, false if we only want the first page
    # @param [DateTime] start_time the time we want to get results back from
    # @param [DateTime] end_time the time we want to get results to, inclusive
    # 
    # @return {Array} If we get all results, this will be an array of the data returned from FB. If we only
    #                 get one page of results, this will be a GraphCollection object that has paging support on it
    def adgroupstats(get_all, start_time = nil, end_time = nil)
      stats_path = path+"/adgroupstats"+self.class.get_stats_query(start_time, end_time)
      
      result = []
      if get_all
        r = get(graph, stats_path)
        while r.to_a.count > 0
          result.concat(r.to_a)
          r = r.next_page
        end
      else
        result = get(graph, stats_path)
      end
      return result
    end
    
  end
end
