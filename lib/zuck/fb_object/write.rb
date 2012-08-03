module Zuck
 module FbObject
   module Write
    def self.included(base)
      base.extend(ClassMethods)
    end

    def save

      # Tell facebook to return
      data = @hash_delegator_hash.merge(redownload: 1)
      data = data.stringify_keys

      # Don't post ids, because facebook doesn't like it
      data = data.keep_if do |k,v|
        next if k[-3..-1] == "_id"
        next if k         == "id"
        next if k[-4..-1] == "_ids"
        next if v.is_a?(Hash)
        next if v.is_a?(Array)
        true
      end

      # Update on facebook
      result = post(graph, path, data)

      # The data is nested by name and id, e.g.
      #
      #     "campaigns" => { "12345" => "data" }
      #
      # Since we only put one at a time, we'll fetch this like that.
      data = result["data"].values.first.values.first

      # Update and return
      set_hash_delegator_data(data)
      result["result"]
    end

    def destroy
      self.class.destroy(graph, path)
    end


    module ClassMethods

      def create(graph, data, parent=nil)
        p = parent.path

        # We want facebook to return the data of the created object
        data["redownload"] = 1

        # Create
        result = create_connection(graph, p, list_path, data)["data"]

        # The data is nested by name and id, e.g.
        #
        #     "campaigns" => { "12345" => "data" }
        #
        # Since we only put one at a time, we'll fetch this like that.
        data = result.values.first.values.first

        # Return a new instance
        new(graph, data, parent)
      end

      def destroy(graph, id)
        delete(graph, id)
      end

    end

   end
 end
end
