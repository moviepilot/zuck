module Zuck
 module FbObject
   module Write
    def self.included(base)
      base.extend(ClassMethods)
    end


    module ClassMethods

      def create(graph, data, parent=nil)

      end

    end

   end
 end
end
