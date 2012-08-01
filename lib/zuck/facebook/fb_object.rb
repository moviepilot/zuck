module Zuck
  # An object that includes {Zuck::HashDelegator} for easy hash
  # access and default keys as methods as well as the `graph`
  # getter and setter from {Zuck::Koala::Methods}.
  #
  # By inheriting from this object, each fb object gets implemented
  # automatically (tm) through calling a couple of DSL methods and
  # defining how an object can obtain its own path.
  #
  # I feel it is example time, here's an imaginary ad campaign:
  #
  #     class AdCampaign < FbObject
  #
  #       known_keys    :title, :budget
  #       parent_object :ad_account
  #       list_path     :adcampaigns
  #
  #     end
  #
  # These handy things are now provided by {FbObject} to your object:
  #
  # 1.  Each `AdCampaign` object has a `title` and `budget` method. In
  #     case facebook returned more information than what's documented
  #     (there are a lot of these), you can still call
  #     `my_campaign[:secret_key]` to get to the juicy bits
  # 2.  You can call `AdCampaign.all(graph, my_ad_account)`, because your
  #     `AdCampaign` instance knows how to construct the path
  #     `act_12345/adcampaigns`. It knows this, because it knows its
  #     parent object and its own list path.
  #
  #
  #
  class FbObject
    include Zuck::HashDelegator
    include Zuck::Koala::Methods

    # @return [String] Most facebook objects will need to return their
    #   id property here, so that's the default. Overwrite if necessary
    def path
      self[:id]
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
    def self.all(graph, parent = nil)
      paths = []
      paths << parent.path if parent
      paths << list_path
      r = get(graph, paths.join('/'))
      r.map do |c|
        new(graph, c, parent)
      end
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

    private

    def set_parent(parent)
      return unless parent
      e = "Invalid parent_object: #{parent.class} is not a #{@parent_object_class}"
      raise e if @parent_object_class and !parent.is_a?(@parent_object_class)
      @parent_object = parent
    end

    # Just a helper for debugging and what not
    def self.get(graph, path)
      # puts "Fetching #{path}"
      graph.get_object(path)
    end

    # Part of our little DSL, sets the part of the path that fetches the
    # list of objects from facebook.
    #
    #     class Foo < FbObject
    #        ...
    #        list_path :foos
    #      end
    #
    # {FbObject} uses this to construct a path together with this class'
    # parent object's path method (which is usually just it's ID
    # property)
    #
    # @param path [String, Symbol] Pass a value if you want to set the
    #   list_path for this object.
    # @return The object's `list_path`
    def self.list_path(path = nil)
      @list_path = path if path
      @list_path
    end

    # Pretty much like a `belongs_to`, but is used to construct paths to
    # access the facebook api.
    #
    # It also defines a getter method. Look
    #
    #     class AdCampaign < FbObject
    #       ...
    #       parent_object :ad_account
    #     end
    #
    # Now on instances you can call `my_campaign.ad_account` to fetch
    # the ad account your campaign is part of.
    #
    # @param type [Symbol] Pass an underscored symbol here, for example
    #   `ad_account`
    def self.parent_object(type)
      @parent_object_type = type.to_s
      @parent_object_class = "Zuck::#{type.to_s.camelcase}".constantize
      define_method(type) do
        @parent_object
      end
    end

    def self.connections(*args)
      args.each do |c|
        define_method(c.to_s.pluralize) do
          clazz = "Zuck::#{c.to_s.singularize.camelize}".constantize
          clazz.all(graph, self)
        end
      end
    end

  end
end
