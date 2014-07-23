require 'zuck/facebook/ad_creative'

module Zuck
  class AdGroup < RawFbObject
    attr_accessor :creative_id

    BID_TYPE_CPC = 'CPC'
    BID_TYPE_CPM = 'CPM'
    BID_TYPE_MULTI_PREMIUM = 'MULTI_PREMIUM'
    BID_TYPE_ABSOLUTE_OCPM = 'ABSOLUTE_OCPM'
    BID_TYPE_CPA = 'CPA'

    STATUS_ACTIVE = 'ACTIVE'
    STATUS_DELETED = 'DELETED'
    STATUS_PENDING = 'PENDING_REVIEW'
    STATUS_DISAPPROVED = 'DISAPPROVED'
    STATUS_PENDING_BILLING = 'PENDING_BILLING_INFO'
    STATUS_CAMPAIGN_PAUSED = 'CAMPAIGN_PAUSED'
    STATUS_PAUSED = 'ADGROUP_PAUSED'

    CONVERSION_ACTION_INSTALL = 'mobile_app_install'
    MOBILE_AND_FACEBOOK_AUDIENCE_NETWORK = 'mobilefeed-and-external'

    REQUIRED_FIELDS = [:name, :bid_type, :bid_info, :campaign_id, :targeting, :objective]

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :account_id,
               :adgroup_status,
               :bid_info,
               :bid_type,
               :campaign_group_id,
               :campaign_id,
               :conversion_specs,
               :created_time,
               :creative_ids,               
               :id,
               :objective,
               # :disapprove_reason_descriptions, # note: this should be reenabled with :adgroup_review_feedback
               :last_updated_by_app_id,
               :name,
               :targeting,
               :tracking_specs,
               :updated_time,
               :view_tags

    parent_object :ad_campaign
    list_path     :adgroups
    connections   :ad_creatives

    # @param graph [Koala::Facebook::API] A graph with access_token
    # @param data [Hash] The properties you want to assign, this is what
    #   facebook gave us (see known_keys).
    # @param parent [<FbObject] A parent context for this class, must
    #   inherit from {Zuck::FbObject}
    def initialize(graph, data = {}, parent=nil)
      super(graph, data, parent)
      @hash_delegator_hash[:bid_type] ||= BID_TYPE_ABSOLUTE_OCPM
    end

    # Sets the bid info object with the appropriate hash data
    # @param {Integer} bid_amount The bid amount in cents
    def set_cpa_bid(bid_amount)
      self.bid_info = {'ACTIONS' => bid_amount}
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
      elsif (!self.conversion_specs && (self.bid_type == BID_TYPE_ABSOLUTE_OCPM || self.bid_type == BID_TYPE_CPA))
        raise "You must specify 'conversion_specs' when the bid_type is OCPM or CPA"
      elsif (!self.id && !self.creative_id)
        raise "You must specify 'creative_id' to save a new AdGroup"
      elsif (self.name && self.name.length > 100)
        raise "The name of this AdGroup is longer than 100 characters"
      end

      args = {
        "creative" => {'creative_id' => self.creative_id.to_s}.to_json,
        "name" => self.name,
        "campaign_id" => self.campaign_id.to_s,
        "bid_type" => self.bid_type,
        "bid_info" => self.bid_info.to_json,        
        "targeting" => self.targeting.to_json,
        "conversion_specs" => self.conversion_specs.to_json,
        "redownload" => 1,
        "objective" => self.objective
      }
      
      # since we don't set the adgroup status initially, we only want to change it if we have an id
      if (self.id)
        args["adgroup_status"] = self.adgroup_status
      end
      
      if (!self.id)
        account_id = Zuck::AdAccount.id_for_api(self.account_id)
        fb_response = Zuck.graph.put_connections(account_id,"adgroups", args)
        if (fb_response && fb_response.has_key?('id'))
          self.id = fb_response['id']
          response = true
        end
      else 
        if (self.is_dirty?)          
          # Build up a hash with the dirty fields
          post_data = {}
          @dirty_keys.each do |dirty_key|
            if (dirty_key == :campaign_id)
              raise "You cannot modify the campaign_id of an Ad Group"
            end
            post_data[dirty_key] = args[dirty_key.to_s]
          end
          
          # The FB API will return true if the save is successful. False otherwise.
          response = Zuck.graph.graph_call(self.id, post_data, "post")        
        end
      end

      reset_dirty if response
      return response
    end

    def self.create(graph, data, ad_campaign)
      path = ad_campaign.ad_account.path
      data['campaign_id'] = ad_campaign.id
      super(graph, data, ad_campaign, path)
    end    

  end
end
