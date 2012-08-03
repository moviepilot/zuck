module Zuck
 module FbObject
   module DSL

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

      # Attempts to resolve the {FbObject.parent_object} to a class at runtime
      # so we can load files in any random order...
      def resolve_parent_object_class
        return if @parent_object_class
        class_s = "Zuck::#{@parent_object_type.camelcase}"
        @parent_object_class = class_s.constantize
      end

      # Makes sure the given parent matches what you defined
      # in {FbObject.parent_object}
      def validate_parent_object_class(parent)
        resolve_parent_object_class
        e = "Invalid parent_object: #{parent.class} is not a #{@parent_object_class}"
        raise e if @parent_object_class and !parent.is_a?(@parent_object_class)
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
      def list_path(path = nil)
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
      def parent_object(type)
        @parent_object_type = type.to_s
        define_method(type) do
          @parent_object
        end
      end

      # Defines which other classes might have this one as their parent.
      #
      # If you do something like
      #
      # ```ruby
      # class Foo < RawFbObject
      #   ...
      #   connections :dings, :dongs
      # end
      # ```
      #
      # then your `Foo` instances will have a `#dings` and `#dongs` methods,
      # which will call `Ding.all` and `Dong.call` on the appropriate graph
      # object.
      #
      # Also, you will get a `#create_ding` and `#create_dong` methods that
      # forward to `Ding.new` and `Dong.new`.
      def connections(*args)
        args.each do |c|

          # Dear reader. You might notice two lines beginning with `clazz = ...`
          # and think WHAT! THIS IS NOT DRY! This is true. What's also true
          # is, that this way the classes are loaded at runtime. This is a
          # good thing because it allows for randomly loading files with classes
          # that inherit from FbObject. 
          #
          # See also {#resolve_parent_object_class}

          # Define getter for connections
          define_method(c.to_s.pluralize) do
            clazz = "Zuck::#{c.to_s.singularize.camelize}".constantize
            clazz.all(graph, self)
          end

          # Define create method for connections
          define_method("create_#{c.to_s.singularize}") do |data|
            clazz = "Zuck::#{c.to_s.singularize.camelize}".constantize
            clazz.create(graph, data, self)
          end
        end
      end
    end
   end
 end
end

