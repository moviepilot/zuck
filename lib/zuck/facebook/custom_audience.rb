module Zuck
  class CustomAudience < RawFbObject

    REQUIRED_FIELDS = [:name]

    LOOKALIKE_MINIMUM_SIZE = 500
    FACEBOOK_BATCH_SIZE = 10000

    known_keys :id,
               :account_id,
               :approximate_count,
               :lookalike_audience_ids,
               :name,
               :description,
               :parent_audience_id,
               :parent_category,
               :status,
               :subtype,
               :type,
               :type_name,
               :time_updated


    parent_object :ad_account
    list_path :customaudiences

    # Types of lookalike audience
    LOOKALIKE_TYPE_SIMILARITY = "similarity"
    LOOKALIKE_TYPE_REACH = "reach"

    LOOKALIIKE_TYPES = [
      LOOKALIKE_TYPE_SIMILARITY,
      LOOKALIKE_TYPE_REACH
    ]

    # Id Types accepted by Facebook
    EMAIL='email_hash'
    IDFA='mobile_advertiser_id'
    PHONE_NUMBER='phone_hash'
    FACEBOOK_ID='id'
    THIRD_PARTY_ID='custom_audience_third_party_id'

    ID_TYPES = [
      EMAIL,
      IDFA,
      PHONE_NUMBER,
      FACEBOOK_ID,
      THIRD_PARTY_ID
    ]

    HASHED_ID_TYPES =[
      EMAIL,
      PHONE_NUMBER
    ]

    # @param graph [Koala::Facebook::API] A graph with access_token
    # @param data [Hash] The properties you want to assign, this is what
    #   facebook gave us (see known_keys).
    # @param parent [<FbObject] A parent context for this class, must
    #   inherit from {Zuck::FbObject}
    def initialize(graph, data = {}, parent=nil)
      super(graph, data, parent)
    end


    # Saves the current custom audience to Facebook
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
        "description" => self.description
      }  

      if (!self.id)
        fb_response = Zuck.graph.put_connections("act_#{self.account_id}" ,"customaudiences", args)
        if (fb_response && fb_response.has_key?('id'))
          self.id = fb_response['id']
          response = true
        end
      else 
        raise "Updating custom audiences not yet supported."
      end
      
      reset_dirty if response
      return response
     end


    # Populate a custom audience with set of facebook ids
    # @param ids [Array] Array of ids in the audience
    # @param id_type [String] Type of the id's
    #
    # @return response from Facebook    
     def populate(ids = [], id_type)
      response = false

      if ids.blank?
        raise "You must specify a set of id's to populate this audience with."
      elsif (!self.id)
        raise "You must save this audience before you can populate it."
      else
        batch = 0
        #TODO: Need to add error checking here
        ids.in_groups_of(FACEBOOK_BATCH_SIZE) do |id_batch|
          puts "batch: #{batch}"
          compacted_id_batch = id_batch.compact

          hashified_ids = compacted_id_batch.collect do |id| 
            if HASHED_ID_TYPES.include?(id)
              id = Digest::MD5.hexdigest(id)
            end
            {id_type => id}
          end

          puts "count: " +hashified_ids.count.inspect
          response = Zuck.graph.put_connections(self.id, "users", "users" => hashified_ids.to_json)
          batch += 1
        end
      end

      return response
     end


    # Loads all information available about this audience into the object
    # @return [Zuck::CustomAudience] this audience object
    def hydrate
      if (!self.id)
        raise "You must save this audience before you can hydrate."
      end

      graph_obj = Zuck.graph.graph_call(self.id)
      self.type = graph_obj['type']
      self.time_updated = graph_obj['time_updated']
      self.parent_audience_id = graph_obj['parent_audience_id']
      self.subtype = graph_obj['subtype']
      self.type_name = graph_obj['type_name']
      self.status = graph_obj['status']
      self.approximate_count = graph_obj['approximate_count']
      return self
    end


    # Creates a new lookalike audience from existing custom audience
    # @param {String} type        similarity or reach
    # @param {String} country     members of the lookalike audience will be from this country
    def create_lookalike(type, country)

      self.hydrate

      if type.blank? or !LOOKALIIKE_TYPES.include?(type)
        raise "You must specify a lookalike audience type. (reach or similarity)"
      elsif country.blank? # Add list of acceptable countries
        raise "You must specify which countries you want lookalike audiences for."
      elsif (self.approximate_count < LOOKALIKE_MINIMUM_SIZE)
        raise "Your seed audience needs to be at least #{LOOKALIKE_MINIMUM_SIZE} users to make a lookalike from it."
      end

      # Setup the post body for Facebook
      args = {
        "name" => "#{self.name}-#{type}-#{country}",
        'origin_audience_id' => self.id,
        'lookalike_spec' => { 
          'type' => type, 
          'country' =>  country 
        }.to_json
      }  

      new_audience = Zuck.graph.put_connections("act_#{self.account_id}",'customaudiences', args)
    end
  end #class
end #module