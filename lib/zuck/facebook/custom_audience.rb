module Zuck
  class CustomAudience < RawFbObject

    REQUIRED_FIELDS = [:name]

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
    
    LOOKALIKE_MINIMUM_SIZE = 500
    FACEBOOK_BATCH_SIZE = 10000
    
    # Types of lookalike audience
    LOOKALIKE_TYPE_SIMILARITY = "similarity"
    LOOKALIKE_TYPE_REACH = "reach"
    LOOKALIKE_TYPE_CUSTOM_RATIO = "custom_ratio" # Automatically set as the type when a ratio is set
    
    LOOKALIKE_TYPES = [
      LOOKALIKE_TYPE_SIMILARITY,
      LOOKALIKE_TYPE_REACH,
      LOOKALIKE_TYPE_CUSTOM_RATIO
    ]
    
    # Range of values for custom ratios
    MIN_CUSTOM_RATIO = 0.01
    MAX_CUSTOM_RATIO = 0.20
    
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
      
      # TODO: Need to get data if subtype == 'LOOKALIKE'
      #self.lookalike_ratio = graph_obj['lookalike_spec']['ratio']
      #self.lookalike_type = graph_obj['lookalike_spec']['type']
      #self.lookalike_country = graph_obj['lookalike_spec']['country']
      return self
    end
    
    # Creates a new lookalike audience from existing custom audience
    #
    # @param [String] name        A name for the Zuck::CustomAudience being created
    # @param [String] type        similarity or reach
    # @param [Float]  ratio       A float ratio for this lookalike, only needed if type is 'custom_ratio'
    # @param [String] country     Members of the lookalike audience will be from this country
    #
    # @return [Hash] A response hash with data from our call
    def create_lookalike(name, country, type, ratio=nil)
      
      # Setup the post body for Facebook
      args = {
        "name" => name,
        'origin_audience_id' => self.id,
        'lookalike_spec' => { 
          'country' =>  country 
        }
      }
      
      # Only specify a type OR ratio 
      args['lookalike_spec']['type'] = type if !ratio.present?
      args['lookalike_spec']['ratio'] = ratio if ratio.present?
      
      # Make sure our lookalike params are valid
      Zuck::CustomAudience.validate_lookalike_params(args)
      
      # Load our local data
      self.hydrate
      
      # Make sure our Zuck::CustomAudience is big enough to make a lookalike
      if (self.approximate_count < LOOKALIKE_MINIMUM_SIZE)
        raise "Your seed audience needs to be at least #{LOOKALIKE_MINIMUM_SIZE} users to make a lookalike from it."
      end
      
      # Convert the internal hash to json
      args['lookalike_spec'] = args['lookalike_spec'].to_json
      account_id_uri = Zuck::AdAccount.id_for_api(self.account_id)
      return Zuck.graph.put_connections(account_id_uri,"customaudiences", args)
    end
    
  protected
    
    # Conveience function for validating our input parameters
    #
    # @param [Hash] params A hash of parameters for our Zuck::CustomAudience lookalike
    def self.validate_lookalike_params(params)
      # Validate our inputs
      if params.blank?
        raise "Can't create a lookalike without params"
      elsif !params['name'].present?
        raise "You must specify a name for the lookalike"
      elsif params['lookalike_spec'].blank?
        raise "You must specify a lookalike specs for your lookalike audience"
      else 
        lookalike_specs = params['lookalike_spec']
        ratio = lookalike_specs['ratio']
        type = lookalike_specs['type']
        country = lookalike_specs['country']
        
        # Validate that the country is alpha-2
        if !country.present? || country.length != 2 # TODO: Add list of acceptable countries
          raise "You must specify a valid ISO 3166-1 alpha-2 country code for your lookalike"
        end
        
        # If a ratio is specified, make sure it is within range and type is not specified...
        if ratio.present?
          if ratio < MIN_CUSTOM_RATIO || ratio > MAX_CUSTOM_RATIO
            raise "Custom ratios must be between #{MIN_CUSTOM_RATIO} and #{MAX_CUSTOM_RATIO}"
          elsif type.present? && type != LOOKALIKE_TYPE_CUSTOM_RATIO
            raise "Type can only be specified in the absence of a custom ratio"
          end
        elsif type == LOOKALIKE_TYPE_CUSTOM_RATIO
          raise "Must specify a ratio when using a custom ratio type"
        # ... else if type is specified make sure it is valid [reach / similarity]
        elsif !type.present? || !LOOKALIKE_TYPES.include?(type)
          raise "You must specify a lookalike audience type if a custom ratio is not present. (reach or similarity)"
        end
      end
    end # end validate_lookalike_params
    
  end #class
end #module