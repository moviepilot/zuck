# An object that includes {Zuck::HashDelegator} for easy hash
# access and default keys as methods as well as the `graph`
# getter and setter from {Zuck::Koala::Methods}
module Zuck
  class FbObject
    include Zuck::HashDelegator
    include Zuck::Koala::Methods
    
    def self.get(graph, path)
      graph.get_object(path)
    end

    # Pretty much like a `belongs_to`
    def self.parent_object(type)
      @parent_object_type = type.to_s
      @parent_object_class = "Zuck::#{type.to_s.camelcase}".constantize
      define_method(type) do 
        @parent_object
      end
    end

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

  end
end
