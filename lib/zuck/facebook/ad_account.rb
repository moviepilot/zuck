module Zuck
  class AdAccount < RawFbObject
    
    CAPABILITY_NEW_CAMPAIGN_STRUCTURE = "NEW_CAMPAIGN_STRUCTURE"
    CAPABILITY_HAS_ACCEPTED_MOBILE_APP_ENGAGEMENT_TOS = "HAS_ACCEPTED_MOBILE_APP_ENGAGEMENT_TOS" # Facebook capability which allows us to generate custom audiences

    # Facebook Ad Account Statuses
    STATUS_ACTIVE = 1
    STATUS_DISABLED = 2
    STATUS_UNSETTLED = 3 
    STATUS_PENDING_REVIEW = 7
    STATUS_PENDING_CLOSURE = 100
    STATUS_TEMPORARILY_UNAVAILABLE = 101

    # Facebook Ad Is Personal Values
    PERSONAL_TYPE_NOT_PERSON = 0
    PERSONAL_TYPE_IS_PERSONAL = 2

    # Facebook Ad Currencies
    # Note: Only supporting USD for now
    CURRENCY_USD = "USD"
    
    BATCH_SIZE = 50

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
               :created_time,
               :daily_spend_limit,
               :id,
               :is_personal,
               :name,
               :owner,
               :spend_cap,
               :timezone_id,
               :timezone_name,
               :timezone_offset_hours_utc,
               :tos_accepted,
               :users,
               :tax_id_status


    list_path   'me/adaccounts'
    connections :ad_campaigns, :ad_campaign_groups, :ad_groups, :ad_creatives, :custom_audiences

    # Queries for an an array of all accounts for the current user
    # @return [Array] A list of fully hydrated Account objects
    def self.all(graph = Zuck.graph)
      super(graph)
    end
    
    # @return {Boolean} true if this ad account supports the new campaign structure, false otherwise
    def has_new_campaign_structure?
      return self.capabilities.include?(CAPABILITY_NEW_CAMPAIGN_STRUCTURE)
    end
    
    # Creates a new campaign group object with pointers to the current account
    # @param [Hash] data Initial values for the campaign group's properties. Defaults to an empty Hash
    # @return [Zuck::AdCampaignGroup] A new campaign group object
    def new_campaign_group(data = {})
      data ||= {}
      data[:account_id] ||= self.id
      campaign_group = Zuck::AdCampaignGroup.new(Zuck.graph, data, self)
      return campaign_group
    end
    
    # Creates a new campaign object with pointers to the current account
    # @param [Hash] data Initial values for the campaign's properties. Defaults to an emtpy Hash
    # @return [Zuck::AdCampaign] A new campaign object
    def new_campaign(data = {})
      data ||= {}
      data[:account_id] ||= self.id
      campaign = Zuck::AdCampaign.new(Zuck.graph, data, self)      
      return campaign
    end

    # Creates a new creative object with pointers to the current account
    # @param [Hash] data Initial values for the creative's properties. Defaults to an emtpy Hash
    # @return [Zuck::AdCreative] A new campaign object
    def new_creative(data = {})
      data ||= {}      
      creative = Zuck::AdCreative.new(Zuck.graph, data, self)
      creative.account_id = self.id
      return creative
    end

    # Creates a new custom audience based on a facebook edge
    # @param [Hash] data
    #               :name {String} 
    #               :description {String}
    # @return [Object] CustomAudience Custom audience just created

    def new_custom_audience(data = {})
      data ||= {}      
      data[:account_id] ||= self.account_id #only the number, not the prefix

      #create audiences
      audience = Zuck::CustomAudience.new(Zuck.graph, data, self)

      return audience
    end
    
    # Fetches stats for AdCampaignGroups inside this AdAccount
    # 
    # @param [Array] ids An array of AdCampaignGroup ids to get stats for
    # @param [DateTime] start_time the time we want to get results back from
    # @param [DateTime] end_time the time we want to get results to, inclusive
    #
    # @return [Hash] A hash of ad campaign group id to {"data" => [{"impressions"=>0, "clicks"=>0, ...}]}
    def ad_campaign_group_stats(ids=[], start_time=nil, end_time=nil)
      # if no ids were specified, get the full list of ids
      if !ids || ids.length == 0
        ids = self.ad_campaign_groups.collect{|acg| acg.id}
      end
      
      result = {}
      if ids && ids.length > 0
        fields = [
          'impressions','spent','clicks'
        ]
        
        stats_query_hash = self.class.get_stats_query(start_time, end_time)
        stats_query_hash[:ids] = ids.join(',')
        stats_query_hash[:fields] = fields.join(',')
        stats_path = path+"/stats"
        stats_path += "?" + stats_query_hash.to_query if stats_query_hash.keys.length > 0
        
        result = get(graph, stats_path)
      end
      
      return result
    end

    # gets AdCampaign stats for this AdAccount
    #
    # @param [Boolean] get_all True if we want to page through all results, false if we only want the first page
    # @param [Array] ad_campaign_ids A list of ad campaign ids to specifically get
    # @param [DateTime] start_time the time we want to get results back from
    # @param [DateTime] end_time the time we want to get results to, inclusive
    # 
    # @return [Array] If we get all results, this will be an array of the data returned from FB. If we only
    #                 get one page of results, this will be a GraphCollection object that has paging support on it
    def adcampaignstats(get_all, ad_campaign_ids=[], start_time = nil, end_time = nil)
      stats_query_hash = self.class.get_stats_query(start_time, end_time)
      stats_path = path+"/adcampaignstats"
      if ad_campaign_ids.length > 0 && ad_campaign_ids.length < 200
        stats_query_hash[:campaign_ids] = "[#{ad_campaign_ids.join(',')}]"
      end
      stats_path += "?" + stats_query_hash.to_query if stats_query_hash.keys.length > 0
      
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
    # @param [Boolean] get_all True if we want to page through all results, false if we only want the first page
    # @param [Array] ad_group_ids A list of ad group ids to specifically get
    # @param [DateTime] start_time the time we want to get results back from
    # @param [DateTime] end_time the time we want to get results to, inclusive
    # 
    # @return [Array] If we get all results, this will be an array of the data returned from FB. If we only
    #                 get one page of results, this will be a GraphCollection object that has paging support on it
    def adgroupstats(get_all, ad_group_ids=[], start_time = nil, end_time = nil)
      stats_query_hash = self.class.get_stats_query(start_time, end_time)
      stats_path = path+"/adgroupstats"
      if ad_group_ids.length > 0 && ad_group_ids.length < 200
        stats_query_hash[:adgroup_ids] = "[#{ad_group_ids.join(',')}]"
      end
      stats_path += "?" + stats_query_hash.to_query if stats_query_hash.keys.length > 0
      
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
    # @param [String] account_id The account_id you have
    # @return [String] The account id with the 'act_' prefix
    def self.id_for_api(account_id)
      response = account_id.to_s
      if (account_id && !account_id.to_s.include?("act_"))
        response = "act_#{account_id}"
      end
      return response
    end
    

    # Gets a hash of data for the given account and connection type for the provided
    # array of URIs
    #
    # @param [Array] base_url_list An array of URI strings to batch [e.g. a list of object_story_ids]
    # @param [String] connection_name The type of connection to get data for [e.g. "adcampaigns", "reachestimates"]
    # @param [Hash] params A hash of params for the batch call
    #
    # @return [Hash] A hash of batched data in the form of {uri => data}
    def batch_get_connection_data(base_uri_list, connection_name, params={})
      batch_data = {}
      
      # Cut the array of base URIs into batch sizes...
      base_uri_list.each_slice(BATCH_SIZE).to_a.each do |base_uri_batch|
        self.graph.batch do |batch_api|
          # ... then process it
          base_uri_batch.each do |base_uri|
            batch_api.get_connections(base_uri, connection_name, params) do |result_data|
              batch_data[base_uri] = result_data if Zuck::is_valid_data?(result_data)
            end
          end
        end
      end
      
      return batch_data
    end
   
    # Gets a hash of data for the given account and connection type for the provided
    # array of URIs
    #
    # @param [Array] base_url_list An array of URI strings to batch [e.g. a list of Zuck::AdCampaign ids]
    # @param [Hash] params A hash of params for the batch call
    #
    # @return [Hash] A hash of batched data in the form of {uri => data}
    def batch_get_object_data(base_uri_list, params={})
      batch_data = {}
      
      # Cut the array of base URIs into batch sizes...
      base_uri_list.each_slice(BATCH_SIZE).to_a.each do |base_uri_batch|
        self.graph.batch do |batch_api|
          # ... then process it
          base_uri_batch.each do |base_uri|
            batch_api.get_object(base_uri, params) do |result_data|
              batch_data[base_uri] = result_data if Zuck::is_valid_data?(result_data)
            end
          end
        end
      end
      
      return batch_data
    end
    
    
    
  end
end
