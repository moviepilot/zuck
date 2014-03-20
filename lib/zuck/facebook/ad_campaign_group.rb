module Zuck
  class AdCampaignGroup < RawFbObject
    
    CAMPAIGN_STATUS_ACTIVE = "ACTIVE"
    CAMPAIGN_STATUS_PAUSED = "PAUSED"
    CAMPAIGN_STATUS_DELETED = "DELETED"
    
    REQUIRED_FIELDS = [:name, :campaign_group_status, :account_id]

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adcampaign-alpha)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :account_id,
               :name,
               :campaign_group_status,
               :objective,
               :id

    parent_object :ad_account
    list_path     :adcampaign_groups
    connections   :ad_campaigns

    # @param graph [Koala::Facebook::API] A graph with access_token
    # @param data [Hash] The properties you want to assign, this is what
    #   facebook gave us (see known_keys).
    # @param parent [<FbObject] A parent context for this class, must
    #   inherit from {Zuck::FbObject}
    def initialize(graph, data = {}, parent=nil)
      super(graph, data, parent)
      @hash_delegator_hash[:campaign_group_status] ||= CAMPAIGN_STATUS_PAUSED
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
      end

      # Setup the post body for Facebook
      args = {
        "name" => self.name,
        "campaign_group_status" => self.campaign_group_status
      }  

      if (!self.id)
        fb_response = Zuck.graph.put_connections(self.account_id,"adcampaign_groups", args)
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
      if (self.campaign_group_status != CAMPAIGN_STATUS_DELETED)
        Zuck.graph.delete_object(self.id)
        self.campaign_group_status = CAMPAIGN_STATUS_DELETED
      end
    end

  end
end
