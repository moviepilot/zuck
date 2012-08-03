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

    # Refetches the data from façeboko
    def reload
      data = get(graph, path)
      validate_data(data)
      set_hash_delegator_data(data)
      self
    end

    private

    # Makes sure that the data passed comes from a facebook
    # object of the same type. We check this by comparing
    # the 'group_id' value with the 'id' value, when this
    # is called on a {Zuck::AdGroup} for example.
    #
    # Facebook omits the "ad" prefix sometimes, so we check 
    # for both.
    def validate_data(data)
      long_id_key  = "#{self.class.list_path.to_s.singularize}_id"
      short_id_key = "#{self.class.list_path.to_s.singularize[2..-1]}_id"
      return if data[long_id_key]  and data[long_id_key].to_s  == data["id"].to_s
      return if data[short_id_key] and data[short_id_key].to_s == data["id"].to_s
      if data[long_id_key]
        raise "Invalid type: #{long_id_key} '#{data[long_id_key]}' does not equal id '#{data["id"]}'"
      elsif data[short_id_key]
        raise "Invalid type: #{short_id_key} '#{data[short_id_key]}' does not equal id '#{data["id"]}'"
      else
        raise "Invalid type: neither #{long_id_key} nor #{short_id_key} set"
      end
    end

    module ClassMethods


      def find(id, graph = Zuck.graph)
        new(graph, id: id).reload
      end

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

    end
   end
 end
end
