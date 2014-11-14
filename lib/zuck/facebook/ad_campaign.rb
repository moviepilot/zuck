module Zuck
  class AdCampaign < RawFbObject
    
    BID_TYPE_CPC = 'CPC'
    BID_TYPE_CPM = 'CPM'
    BID_TYPE_MULTI_PREMIUM = 'MULTI_PREMIUM'
    BID_TYPE_ABSOLUTE_OCPM = 'ABSOLUTE_OCPM'
    BID_TYPE_CPA = 'CPA'
    
    CAMPAIGN_STATUS_ACTIVE = "ACTIVE"
    CAMPAIGN_STATUS_PAUSED = "PAUSED"
    CAMPAIGN_STATUS_DELETED = "DELETED"
    CAMPAIGN_STATUS_GROUP_PAUSED = "CAMPAIGN_GROUP_PAUSED"
    CAMPAIGN_STATUS_ARCHIVED = "ARCHIVED"

    REQUIRED_FIELDS = [:name, :bid_type, :bid_info, :campaign_status, :account_id, :targeting, :campaign_group_id]

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :account_id,
               :bid_info,
               :bid_type,
               :campaign_group_id,
               :campaign_status,
               :created_time,
               :daily_imps,
               :end_time,
               :id,
               :daily_budget,
               :lifetime_budget,
               :name,
               :start_time,
               :targeting,
               :updated_time

    parent_object :ad_campaign_group
    list_path     :adcampaigns
    connections   :ad_groups
    

    # @param graph [Koala::Facebook::API] A graph with access_token
    # @param data [Hash] The properties you want to assign, this is what
    #   facebook gave us (see known_keys).
    # @param parent [<FbObject] A parent context for this class, must
    #   inherit from {Zuck::FbObject}
    def initialize(graph, data = {}, parent=nil)
      super(graph, data, parent)
      @hash_delegator_hash[:campaign_status] ||= CAMPAIGN_STATUS_PAUSED
      @hash_delegator_hash[:bid_type] ||= BID_TYPE_ABSOLUTE_OCPM
    end
    
    # @return [Hash] A hash of bid info
    def get_bid_info
      result = self.bid_info
      
      if !result.present?
        # fall back to ad group data if ours is missing
        these_ad_groups = self.ad_groups || []
        if these_ad_groups.first.present?
          result = these_ad_groups.first.bid_info
        end
      end
      
      return result 
    end
    
    # @return [String] The bid type
    def get_bid_type
      result = self.bid_type
      
      if !result.present?
        # fall back to ad group data if ours is missing
        these_ad_groups = self.ad_groups || []
        if these_ad_groups.first.present?
          result = these_ad_groups.first.bid_type
        end
      end
      
      return result
    end
    
    # @return [Hash] A hash of targeting spec info
    def get_targeting
      result = self.targeting
      
      if !result.present?
        # fall back to ad group data if ours is missing
        these_ad_groups = self.ad_groups || []
        if these_ad_groups.first.present?
          result = these_ad_groups.first.targeting
        end
      end
      
      return result
    end
    
    # Sets the bid info object with the appropriate hash data
    # @param {Integer} bid_amount The bid amount in cents
    def set_cpa_bid(bid_amount)
      self.bid_info = {'ACTIONS' => bid_amount}
    end
    
    # Creates a new Ad Group object with pointers to the current campaign and account
    # @param {Hash} data Initial values for the Ad Group's properties. Defaults to an emtpy Hash
    # @return {Zuck::AdGroup} A new ad group object
    def new_ad_group(data = {})
      # Setup the default params
      data ||= {}
      data[:account_id] ||= self.account_id
      data[:campaign_id] ||= self.id
      
      # Create the new ad group and return it
      ad_group = Zuck::AdGroup.new(Zuck.graph, data, self)
      # We need to workaround the creative_id field because it is not a 'known_key' for GETs
      ad_group.creative_id ||= data[:creative_id] if data[:creative_id]
      
      return ad_group
    end    

    # Saves the current creative to Facebook
    # @throws Exception If not all required fields are present
    # @throws Exception If you try to save an exsiting record because we don't support updates yet
    def save
      response = false

      active_fields = self.data.keys
      missing_fields = (REQUIRED_FIELDS - active_fields)
      if (missing_fields.length != 0)
        raise "You need to set the following fields before saving: #{missing_fields.join(', ')}"
      elsif (!self.daily_budget && !self.lifetime_budget)
        raise "You must specifiy either a daily or lifetime_budget"
      elsif (self.lifetime_budget && self.lifetime_budget > 0 && !self.end_time)
        raise "You must specify an end_time for campaigns with lifetime budgets"
      end

      # Setup the post body for Facebook
      args = {
        "name" => self.name,
        "campaign_group_id" => self.campaign_group_id,
        "campaign_status" => self.campaign_status,
        "daily_budget" => self.daily_budget.to_i,
        "lifetime_budget" => self.lifetime_budget.to_i,
        "start_time" => self.start_time,
        "end_time" => self.end_time,
        "bid_type" => self.get_bid_type,
        "bid_info" => self.get_bid_info.to_json,
        "targeting" => self.get_targeting.to_json,
        "redownload" => true
      }

      if (!self.id)
        account_id = Zuck::AdAccount.id_for_api(self.account_id)
        fb_response = Zuck.graph.put_connections(account_id,"adcampaigns", args)
        if (fb_response && fb_response.has_key?('id'))
          self.id = fb_response['id']
          response = true
        end
      else 
        if (self.is_dirty?)
          # Build up a hash with the dirty fields
          post_data = {}
          @dirty_keys.each do |dirty_key|
            post_data[dirty_key] = args[dirty_key.to_s]
          end
          
          # The FB API will return true if the save is successful. False otherwise.
          response = Zuck.graph.graph_call(self.id, post_data, "post")        
        end
      end

      reset_dirty if response
      return response
    end

    # Trigger a soft-delete
    def delete
      if (self.campaign_status != CAMPAIGN_STATUS_DELETED)
        Zuck.graph.delete_object(self.id)
        self.campaign_status = CAMPAIGN_STATUS_DELETED
      end
    end

    # gets conversion info for a campaign
    def conversions
      r = get(graph, path+"/conversions")
    end

  end
end
