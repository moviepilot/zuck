module Zuck
 module FbObject
   module Write
    def self.included(base)
      base.extend(ClassMethods)
    end

    def save

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
        result = put(graph, p, list_path, data)["data"]

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
