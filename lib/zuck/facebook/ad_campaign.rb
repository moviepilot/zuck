module Zuck
  class AdCampaign < RawFbObject

    CAMPAIGN_STATUS_ACTIVE = 1
    CAMPAIGN_STATUS_PAUSED = 2

    REQUIRED_FIELDS = [:name, :campaign_status, :account_id]

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :account_id,
               :campaign_status,
               :created_time,
               :daily_imps,
               :end_time,
               :id,
               :daily_budget,
               :lifetime_budget,
               :name,
               :start_time,
               :updated_time

    parent_object :ad_account
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
    end

    # Creates a new Ad Group object with pointers to the current campaign and account
    # @param {Hash} data Initial values for the Ad Group's properties. Defaults to an emtpy Hash
    # @return {Zuck::AdGroup} A new ad group object
    def new_ad_group(data = {})
      if (!self.id)
        raise "You must save this campaign before you can create Ad Groups for it"
      end

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
      elsif (self.lifetime_budget && !self.end_time)
        raise "You must specify an end_time for campaigns with lifetime budgets"
      end

      # Setup the post body for Facebook
      args = {
        "name" => self.name,
        "campaign_status" => self.campaign_status,
        "daily_budget" => self.daily_budget.to_i,
        "lifetime_budget" => self.lifetime_budget.to_i,
        "start_time" => self.start_time,
        "end_time" => self.end_time,
        "redownload" => true
      }  

      if (!self.id)
        fb_response = Zuck.graph.put_connections(self.account_id,"adcampaigns", args)
        if (fb_response && fb_response.has_key?('id'))
          self.id = fb_response['id']
          response = true
        end
      else 
        # TODO: potentially support updating a creative
        raise "Updates are not yet implemented for campaigns"
      end

      return response
    end

    # gets conversion info for a campaign
    def conversions
      r = get(graph, path+"/conversions")
    end

  end
end
