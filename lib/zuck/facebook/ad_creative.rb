module Zuck
  class AdCreative < RawFbObject
    attr_accessor :account_id

    CREATIVE_TYPE_MOBILE_APP = 32
    CREATIVE_STORE_ITUNES = "itunes"
    CREATIVE_STORE_IPAD = "itunes_ipad"
    CREATIVE_STORE_ANDROID = "google_play"

    REQUIRED_FIELDS = [:type, :object_id, :mobile_store, :title, :body, :image_hash]

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :name,
               :type,
               :object_id,
               :body,
               :image_hash,
               :image_url,
               :id,
               :title,
               :link_url,
               :url_tags,
               :preview_url,
               :related_fan_page,
               :auto_update,
               :story_id,
               :action_spec,
               :mobile_store

    parent_object :ad_group
    list_path     :adcreatives


    # @param graph [Koala::Facebook::API] A graph with access_token
    # @param data [Hash] The properties you want to assign, this is what
    #   facebook gave us (see known_keys).
    # @param parent [<FbObject] A parent context for this class, must
    #   inherit from {Zuck::FbObject}
    def initialize(graph, data = {}, parent=nil)
      super(graph, data, parent)
      self.type ||= CREATIVE_TYPE_MOBILE_APP
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
      elsif (!self.account_id)
        raise "You need to set the account_id field in order to save this object"
      end

      args = {
        "type" => self.type,
        "object_id" => self.object_id.to_i,
        "mobile_store" => self.mobile_store,
        "title" => self.title,
        "body" => self.body,
        "image_hash" => self.image_hash,
        "name" => self.name    
      }      

      if (!self.id)
        fb_response = Zuck.graph.put_connections(self.account_id,"adcreatives", args)
        if (fb_response && fb_response.has_key?('id'))
          self.id = fb_response['id']
          response = true
        end
      else 
        # TODO: potentially support updating a creative
        raise "Updates are not yet implemented for creatives"
      end

      return response
    end

    # Instance helper to upload an image and append it's info to the current object
    # @param {String} account_id The account to target
    # @param {String} path The location of the file to upload
    # @return {Boolean} Indicates whether the file upload was successful
    def upload_image(account_id, path)
      response = false
      image_info = Zuck::AdCreative.upload_image(account_id, path)
      if (image_info)
        self.image_hash = image_info['hash']
        self.image_url = image_info['url']
        response = true
      end

      return response
    end
    
    # Static helper to upload images to the Ad Library
    # @param {String} account_id The account to target
    # @param {String} path The location of the file to upload
    # @response {Hash} Info about the image in FB's system, nil if there was a failure
    #                   {"hash"=>"15d7e2fea678eb6366bbc318a5dfca3f", 
    #                   "url"=>"https://fbcdn-creative-a.akamaihd.net/hads-ak-frc3/1354208_6011846295334_858426988_n.png"} 
    def self.upload_image(account_id, path)
      account_id = Zuck::AdAccount.id_for_api(account_id)
      image = Koala::UploadableIO.new(path)
      args = {"test.jpg" => image}
      response = Zuck.graph.put_connections(account_id,"adimages", args)
      images = response['images'] if response
      image_info = images ? images.values[0] : nil

      return image_info
    end

  end
end
