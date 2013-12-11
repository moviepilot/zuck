module Zuck
  class CustomAudience < RawFbObject

    REQUIRED_FIELDS = [:name]

    LOOKALIKE_MINIMUM_SIZE = 500
    FACEBOOK_BATCH_SIZE = 10000

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.

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
               :subtype_name,
               :type,
               :type_name,
               :time_updated


    parent_object :ad_account
    list_path :customaudiences


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
    # @param data [Hash] The properties you want to assign, this is what    
     def populate(ids = [])
      response = false


      if ids.blank?
        raise "You must specify a set of Facebook id's to populate this audience with."
      elsif (!self.id)
        raise "You must save this audience before you can populate it."
      else
        batch = 0
        ids.in_groups_of(FACEBOOK_BATCH_SIZE) do |id_batch|
          puts "batch: #{batch}"
          args = {
            'users' => id_batch.compact.to_json 
          }
          response = Zuck.graph.put_connections(self.id, "users", args)
          batch += 1
        end
      end

      return response
     end


    # Creates a new custom audience based on a facebook edge
    # @param {Array} types of lookalikes to create similarity or reach (or both)
    # @param {Array} countries for which to create lookalikes
    def create_lookalike_set(types = [], countries = [])

      self.hydrate

      if (types.blank?)
        raise "You must specify which types of lookalike audiences you want to create."
      elsif (countries.blank?)
        raise "You must specify which countries you want lookalike audiences for."
      elsif (self.approximate_count < LOOKALIKE_MINIMUM_SIZE)
        raise "Your seed audience needs to be at least #{LOOKALIKE_MINIMUM_SIZE} users to make a lookalike from it."
      end

      types.each do |type|
        countries.each do |country|

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
      end
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
      self.subtype_name = graph_obj['subtype_name']
      self.type_name = graph_obj['type_name']
      self.status = graph_obj['status']
      self.approximate_count = graph_obj['approximate_count']
      return self
    end




    # List of facebook user ids who liked a certain facebook edge
    # @param {Integer} :
    # @param {Array} :countries {Array} list of countries to create audiences for
    # @return [Array] List of ids
    def get_likers_for_custom_edge(app_id, edge_ids)
      ids = []
      edge_ids.each_with_index do |edge_id, i|
        sleep(1)
        puts "Edge #{i + 1}"
        response = Zuck.graph.graph_call("#{app_id}_#{edge_id}/likes/?limit=1000&fields=id")
        while response.present?
          ids += response
          sleep(0.25)
          response = response.next_page
        end
         File.open('/Users/davidpekar/Desktop/bb.txt','w') {|f| f.write(ids.to_s)}


      end

      return ids
    end



  end
end 