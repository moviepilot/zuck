module Zuck
 module FbObject
   module Configuration
    def self.included(base)
      base.extend(ClassMethods)
    end

    # @return [String] Most facebook objects will need to return their
    #   id property here, so that's the default. Overwrite if necessary
    def path
      self[:id]
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
    end
   end
 end
end

