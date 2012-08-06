module Zuck
  class ZuckError < StandardError; end
  module Error

    class ReadOnly < ::Zuck::ZuckError; end

  end
end
