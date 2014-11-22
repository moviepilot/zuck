module Zuck
  class CustomAudience < RawFbObject

    REQUIRED_FIELDS = [:name]

    known_keys :id,
               :account_id,
               :approximate_count,
               :data_source,
               :delivery_status,
               :description,
               :lookalike_audience_ids,
               :lookalike_spec,
               :name,
               :operation_status,
               :permission_for_actions,
               :retention_days,
               :rule,
               :subtype,
               :time_content_updated,
               :time_created,
               :time_updated
               
    parent_object :ad_account
    list_path :customaudiences
    
    DELIVERY_STATUS = {
      :ready => 200,              # This audience is ready for use.
      :too_small => 300          # Audiences must include at least 20 people to be used for ads.
    }
    
    OPERATION_STATUS = {
      :not_avilable => 0,        # Status not available
      :normal => 200,            # Normal: there is no updating or issues found.
      :updating => 300,          # Updating: there is an ongoing updating on the audience
      :warning => 400,           # Warning: there is some message we would like advertisers to know
      :no_upload => 410,         # No upload: no file has been uploaded
      :low_match_rate => 411,    # Low match rate: low rate of matched people
      :high_invalid_rate => 412, # High invalid rate: high rate of invalid people
      :no_pixel => 421,          # No pixel: Your Custom Audience pixel hasn't been installed on your website yet
      :pixel_not_firing => 422,  # Pixel not firing: Your Custom Audience pixel isn't firing
      :invalid_pixel => 423,     # Invalid pixel: Your Custom Audience pixel is invalid
      :refresh_failed => 431,    # Audience refresh failed
      :build_failed_1 => 432,    # Audience build failed
      :build_failed_2 => 433,    # Audience build failed
      :build_retrying => 434,    # Audience build retrying
      :error => 500              # Error: there is some error and advertisers need to take action items to fix the error
    }
    
    LOOKALIKE_MINIMUM_PARENT_AUDIENCE_SIZE = 500
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
    
    # ratios for the given lookalike types
    SIMILARITY_RATIO = 0.01
    REACH_RATIO = 0.05
    
    # Range of values for lookalike ratios
    MIN_LOOKALIKE_RATIO = 0.01
    MAX_LOOKALIKE_RATIO = 0.20
    
    LOOKALIKE_RATIO_STEP_SIZE = 0.01
    
    # retention values
    MAX_RETENTION_DAYS=180 #Facebook allows you to retain the last x days of users in your custom audience, 180 is the max
    
    # audience types
    AUDIENCE_TYPE_APP = "app"
    
    # event types
    EVENT_TYPE_APP_INSTALLS = "fb_mobile_first_app_launch"
    
    # Id Types accepted by Facebook for Custom Audience population
    FACEBOOK_ID='UID'
    EMAIL='EMAIL_SHA256'
    PHONE_NUMBER='PHONE_SHA_256'
    IDFA='MOBILE_ADVERTISER_ID'

    ID_TYPES = [
      EMAIL,
      IDFA,
      PHONE_NUMBER,
      FACEBOOK_ID
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
          compacted_id_batch = id_batch.compact

          hashified_ids = compacted_id_batch.collect do |id| 
            if HASHED_ID_TYPES.include?(id)
              id = Digest::SHA256.hexdigest(id)
            end
            id
          end
          payload = {
            :schema => id_type,
            :data => hashified_ids
          }

          response = Zuck.graph.put_connections(self.id, "users", "payload" => payload.to_json)
          
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
      
      fields = [
        :time_updated,
        :subtype,
        :approximate_count
      ]

      graph_obj = Zuck.graph.graph_call(self.id, {:fields => fields})
      self.time_updated = graph_obj['time_updated']
      self.subtype = graph_obj['subtype']
      self.approximate_count = graph_obj['approximate_count']
      
      # TODO: Need to get data if subtype == 'LOOKALIKE'
      #self.lookalike_ratio = graph_obj['lookalike_spec']['ratio']
      #self.lookalike_type = graph_obj['lookalike_spec']['type']
      #self.lookalike_country = graph_obj['lookalike_spec']['country']
      return self
    end
    
    # Creates a root Zuck::CustomAudience object for a given app
    #
    # @param [String] name The name of the project we are creating a root audience for
    # @param [String] facebook_app_id The facebook_app_id we are creating the audience for
    # @param [String] account_id The id of the Zuck::AdAccount
    #
    # @return [Hash] A hash of data in the form of {id => integer} containing the service_foreign_id for the newly created audience 
    def self.create_root_audience(name, description, facebook_app_id, account_id)
      # This data mirrors the internal calls made by Facebook on their web ads product
      # There is no documentation for this data
      args = {
        "inclusions" => [{
          "retention_days" => MAX_DAYS_BACK_TO_RETAIN,
          "type" => AUDIENCE_TYPE_APP,
          "rule" => {
            "_application" => facebook_app_id,
            "_eventName" => EVENT_TYPE_APP_INSTALLS
          }
        }].to_json,
        "accountId" => account_id,
        "name" => name,
        "description" => description,
        "subtype" => "combination",
        "pretty" => 0 
      }
      
      return self.create_remote_custom_audience(account_id, args)
    end
    
    # Creates a new lookalike audience from existing custom audience
    #
    # @param [Zuck::CustomAudience] parent_audience  The audience to create a lookalike for
    # @param [String] name                           A name for the Zuck::CustomAudience being created
    # @param [String] description                    A description for this audience
    # @param [String] country                        Members of the lookalike audience will be from this country
    # @param [Float]  ratio                          A float ratio for this lookalike, only needed if type is 'custom_ratio'
    #
    # @return [Hash] A response hash with data from our call
    def self.create_lookalike(parent_audience, name, description, country, ratio)
      # make sure we have a parent object
      if !parent_audience.present?
        raise "Parent custom audience is required to create a lookalike."
      end
      
      # Setup the post body for Facebook
      args = {
        "name" => name,
        'description' => description,
        'origin_audience_id' => parent_audience.id,
        'lookalike_spec' => { 
          'country' =>  country,
          'ratio' => ratio
        }
      }
      
      # Make sure our lookalike params are valid
      self.validate_default_lookalike_params(args)
      
      # Load our local data
      parent_audience.hydrate
      
      # Make sure our Zuck::CustomAudience is big enough to make a lookalike
      if (parent_audience.approximate_count < LOOKALIKE_MINIMUM_PARENT_AUDIENCE_SIZE)
        raise "Your seed audience needs to be at least #{LOOKALIKE_MINIMUM_PARENT_AUDIENCE_SIZE} users to make a lookalike from it."
      end
      
      # Convert the internal hash to json
      args['lookalike_spec'] = args['lookalike_spec'].to_json
      
      return self.create_remote_custom_audience(parent_audience.account_id, args)
    end
    
  protected
    
    # Convenience function for validating our input parameters for a default lookalike audience
    #
    # @param [Hash] params A hash of parameters for our Zuck::CustomAudience lookalike
    def self.validate_default_lookalike_params(params)
      # Validate our inputs
      if params.blank?
        raise "Can't create a lookalike without params"
      elsif !params['name'].present?
        raise "You must specify a name for the lookalike"
      elsif params['lookalike_spec'].blank?
        raise "You must specify a lookalike spec for your lookalike audience"
      else 
        lookalike_specs = params['lookalike_spec']
        ratio = lookalike_specs['ratio']
        type = lookalike_specs['type']
        
        # validate the country code
        self.validate_country_code(lookalike_specs['country'])
        
        # If a ratio is specified, make sure it is within range and type is not specified...
        if ratio.present?
          # validate the ratio values
          self.validate_ratio(ratio)
          
          if type.present? && type != LOOKALIKE_TYPE_CUSTOM_RATIO
            raise "Type can only be specified in the absence of a custom ratio"
          end
        elsif type == LOOKALIKE_TYPE_CUSTOM_RATIO
          raise "Must specify a ratio when using a custom ratio type"
        # ... else if type is specified make sure it is valid [reach / similarity]
        elsif !type.present? || !LOOKALIKE_TYPES.include?(type)
          raise "You must specify a lookalike audience type if a custom ratio is not present. (reach or similarity)"
        end
      end
    end # end validate_default_lookalike_params
    
    # Convenience function for validating a country code as alpha-2
    #
    # @param [String] country The country code to validate
    def self.validate_country_code(country)
      if !country.present? || country.length != 2 # TODO: Add list of acceptable countries
        raise "You must specify a valid ISO 3166-1 alpha-2 country code for your lookalike"
      end
    end
    
    # Convenience function for validating a ratio
    #
    # @param [Float] ratio The ratio to validate
    def self.validate_ratio(ratio)
      if ratio.present? && (ratio < MIN_LOOKALIKE_RATIO || ratio > MAX_LOOKALIKE_RATIO)
        raise "Custom ratios must be between #{MIN_LOOKALIKE_RATIO} and #{MAX_LOOKALIKE_RATIO}"
      end
    end
    
    # Convenience function that handles the creation of a custom audience
    #
    # @param [String] account_id The account id to create the custom audience for
    # @param [Hash] args The custom audience parameters
    #
    # @return [Zuck::CustomAudience] The audience that was created
    def self.create_remote_custom_audience(account_id, args)
      if !account_id.present?
        raise "Must have a valid account id to create a custom audience."
      end
      
      account_id_uri = Zuck::AdAccount.id_for_api(account_id)
      return Zuck.graph.put_connections(account_id_uri,"customaudiences", args)
    end
    
  end #class
end #module