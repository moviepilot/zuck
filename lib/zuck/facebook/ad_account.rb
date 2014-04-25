module Zuck
  class AdAccount < RawFbObject
    
    NEW_CAMPAIGN_STRUCTURE_CAPABILITY = 28

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
    connections :ad_campaigns, :ad_campaign_groups, :ad_groups, :custom_audiences

    # Queries for an an array of all accounts for the current user
    # @return {Array} A list of fully hydrated Account objects
    def self.all(graph = Zuck.graph)
      super(graph)
    end
    
    # @return {Boolean} true if this ad account supports the new campaign structure, false otherwise
    def has_new_campaign_structure?
      return self.capabilities.include?(NEW_CAMPAIGN_STRUCTURE_CAPABILITY)
    end
    
    # Creates a new campaign group object with pointers to the current account
    # @param {Hash} data Initial values for the campaign group's properties. Defaults to an empty Hash
    # @return {Zuck::AdCampaignGroup} A new campaign group object
    def new_campaign_group(data = {})
      data ||= {}
      data[:account_id] ||= self.id
      campaign_group = Zuck::AdCampaignGroup.new(Zuck.graph, data, self)
      return campaign_group
    end
    
    # Creates a new campaign object with pointers to the current account
    # @param {Hash} data Initial values for the campaign's properties. Defaults to an emtpy Hash
    # @return {Zuck::AdCampaign} A new campaign object
    def new_campaign(data = {})
      data ||= {}
      data[:account_id] ||= self.id
      campaign = Zuck::AdCampaign.new(Zuck.graph, data, self)      
      return campaign
    end

    # Creates a new creative object with pointers to the current account
    # @param {Hash} data Initial values for the creative's properties. Defaults to an emtpy Hash
    # @return {Zuck::AdCreative} A new campaign object
    def new_creative(data = {})
      data ||= {}      
      creative = Zuck::AdCreative.new(Zuck.graph, data, self)
      creative.account_id = self.id
      return creative
    end

    # Creates a new custom audience based on a facebook edge
    # @param {Hash} data
    #               :name {String} 
    #               :description {String}
    # @return {Object} CustomAudience Custom audience just created

    def new_custom_audience(data = {})
      data ||= {}      
      data[:account_id] ||= self.account_id #only the number, not the prefix

      #create audiences
      audience = Zuck::CustomAudience.new(Zuck.graph, data, self)

      return audience
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

    # Helper method to make sure that a given Account Id has the prefix needed to be used for Graph API calls
    # @param {String} account_id The account_id you have
    # @return {String} The account id with the 'act_' prefix
    def self.id_for_api(account_id)
      response = account_id.to_s
      if (account_id && !account_id.to_s.include?("act_"))
        response = "act_#{account_id}"
      end
      return response
    end
    
  end
end
