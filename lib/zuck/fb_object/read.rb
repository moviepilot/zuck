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
      def initialize(graph, data = {}, parent=nil)
        self.graph = graph
        set_data(data)

        # If the parent is an {AdAccount} we only want to set it as this
        # object's direct parent when this object is an {AdSet}.
        # if !parent.is_a?(AdAccount) or (parent.is_a?(AdAccount) and self.is_a?(AdSet))
        #   set_parent(parent)
        # end
      end

      # Refetches the data.
      def reload
        begin
          data = get(graph, path)
          set_data(data)
        rescue Exception => e
          puts e.inspect
        end
        self
      end

      private

      # Sets the parent of this instance
      #
      # @param parent [FbObject] Has to be of the same class type you defined
      #   using {FbObject.parent_object}
      def set_parent(parent)
        return unless parent
        self.class.validate_parent_object_class(parent)
        @parent_object = parent
      end

      module ClassMethods

        # Finds by object id and checks type.
        def find(id, graph = Zuck.graph)
          new(graph, id: id).reload
        end

        # Automatique all getter.
        #
        # Let's say you want to fetch all campaigns
        # from facebook. This can happen in the context of an ad
        # account. In this gem, that context is called a parent. This method
        # would only be called on objects that inherit from {FbObject}.
        # It asks the `parent` for it's path (if it is given), and appends
        # it's own `list_path` property that you have defined (see
        # list_path)
        #
        # If, however, you want to fetch all ads, regardless of
        # which ad set is their parent, you can omit the `parent`
        # parameter. The ads returned by `Zuck::Ad.all` will
        # return `nil` when you call `#ad_set` on them, though, because facebook
        # will not return this information. So if you can, try to fetch
        # objects through their direct parent, e.g.
        # `my_ad_group.ad_sets`.
        #
        # @param graph [Koala::Facebook::API] A graph with access_token
        # @param parent [<FbObject] A parent object to scope
        def all(graph = Zuck.graph, parent = nil)
          parent ||= parent_ad_account_fallback
          r = get(graph, path_with_parent(parent))
          r.map do |c|
            new(graph, c, parent)
          end
        end

        # Makes sure the given parent matches what you defined
        # in {FbObject.parent_object}
        def validate_parent_object_class(parent)
          resolve_parent_object_class
          e = "Invalid parent_object: #{parent.class} is not a #{@parent_object_class}"
          raise e if @parent_object_class and !parent.is_a?(@parent_object_class)
        end

        private


        # Attempts to resolve the {FbObject.parent_object} to a class at runtime
        # so we can load files in any random order...
        def resolve_parent_object_class
          return if @parent_object_class
          class_s = "Zuck::#{@parent_object_type.camelcase}"
          @parent_object_class = class_s.constantize
        end

        # Some objects can be fetched "per account" or "per parent
        # object", e.g. you can fetch all ads for your account
        # or only for an ad set.
        #
        # @return [nil, Zuck::FbObject] Returns the current ad account
        #   unless you're calling `Zuck::AdAccount.all`. Then we return
        #   nil because the ad account needs no parent.
        def parent_ad_account_fallback
          return nil if self == Zuck::AdAccount
          Zuck::AdAccount.all.first
        end

      end

    end
  end
end
