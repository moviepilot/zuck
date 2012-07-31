module Zuck
  class AdCampaign < FbObject

    def self.all(graph, ad_account)
      r = get(graph, "act_#{ad_account.account_id}/adcampaigns")
      r.map do |c|
        new(graph, ad_account, c)
      end
    end

    def initialize(graph, campaign, data)
      self.graph = graph
      set_hash_delegator_data(data)
      @campaign = campaign
    end

    def groups

    end

  end
end
