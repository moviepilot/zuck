module Zuck
  class AdAccount

    def self.all(graph = Zuck.graph)
      r = graph.get_object('/adAccounts')
      r.map do |a|
        new(graph, a)
      end
    end

    def initialize(graph, data)

    end

  end
end
