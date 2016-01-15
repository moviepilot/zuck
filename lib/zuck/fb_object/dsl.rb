require_relative 'error'

module Zuck
 module FbObject
   module DSL

    def self.included(base)
      base.extend(ClassMethods)
    end

    # @return [String] Most facebook objects will need to return their
    #   id property here, so that's the default. Overwrite if necessary
    def path
      self[:id] or raise "Can't find a path unless I have an id #{self.inspect}"
    end

    module ClassMethods

      # Don't allow create/update/delete
      def read_only
        @read_only = true
      end

      def read_only?
        !!@read_only
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
      #     class AdSet < FbObject
      #       ...
      #       parent_object :ad_account
      #     end
      #
      # Now on instances you can call `my_campaign.ad_account` to fetch
      # the ad account your campaign is part of.
      #
      # @param type [Symbol] Pass an underscored symbol here, for example
      #   `:ad_account`
      def parent_object(type, options = {})

        # The `Read` module uses this
        @parent_object_type = type.to_s

        define_method(type) do
          # Why a lambda? Because it gets evaluated on runtime, not now. This is a
          # good thing because it allows for randomly loading files with classes
          # that inherit from FbObject.
          class_resolver = lambda{"Zuck::#{type.to_s.singularize.camelize}".constantize}

          if options[:as]
            @parent_object ||= class_resolver.call.new(@graph, {id: send(options[:as])}, nil)
          else
            @parent_object
          end
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
          class_resolver = lambda{"Zuck::#{c.to_s.singularize.camelize}".constantize}

          # Define getter for connections
          define_method(c.to_s.pluralize) do
            class_resolver.call.all(graph, self)
          end

          # Define create method for connections
          define_method("create_#{c.to_s.singularize}") do |data|
            class_resolver.call.create(graph, data, self)
          end
        end
      end
    end
   end
 end
end
