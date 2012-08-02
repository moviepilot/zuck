module Zuck
  module FbObject
    module Helpers
      def path_with_parent(parent)
        paths = []
        paths << parent.path if parent
        paths << list_path
        paths.join('/')
      end
    end
  end
end
