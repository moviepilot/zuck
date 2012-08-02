module Zuck
 module FbObject
   module Read
    def self.included(base)
      base.extend(ClassMethods)
    end

    # @param graph [Koala::Facebook::API] A graph with access_token
    # @param data [Hash] The properties you want to assign, this is what
    #   facebook gave us (see known_keys).
    # @param parent [<FbObject] A parent context for this class, must
    #   inherit from {Zuck::FbObject}
    def initialize(graph, data, parent=nil)
      self.graph = graph
      set_hash_delegator_data(data)
      set_parent(parent)
    end

    module ClassMethods

      # Automatique all getter.
      #
      # Let's say you want to fetch all campaigns
      # from facebook. This can only happen in the context of an ad
      # account. In this gem, that context is called a parent. This method
      # would only be called on objects that inherit from {FbObject}.
      # It asks the `parent` for it's path (if it is given), and appends
      # it's own `list_path` property that you have defined (see
      # list_path)
      #
      # @param graph [Koala::Facebook::API] A graph with access_token
      # @param parent [<FbObject] A parent object (needed always, except
      #   when you fetch a {Zuck::AdAccount}
      def all(graph, parent = nil)
        r = get(graph, path_with_parent(parent))
        r.map do |c|
          new(graph, c, parent)
        end
      end

      private

      # Just a helper for debugging and what not
      def get(graph, path)
        # puts "Fetching #{path}"
        graph.get_object(path)
      end

    end
   end
 end
end
