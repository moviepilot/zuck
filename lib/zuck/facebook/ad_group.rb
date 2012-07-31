require_relative 'fb_object'

module Zuck
  class AdGroup < FbObject

    def self.all(graph, campaign)
      r = get(graph, "#{campaign.id}/adgroups")
      r.map do |g|
        new(graph, campaign, g)
      end
    end

    def initialize(graph, campaign, data)
      self.graph = graph
      set_hash_delegator_data(data)
      @campaign = campaign
    end

  end
end
