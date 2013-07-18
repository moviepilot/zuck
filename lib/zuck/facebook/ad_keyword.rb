module Zuck
  module AdKeyword
    extend Zuck::Helpers
    extend self

    # Checks the ad api to see if the given keywords are valid
    # @return [Hash] The keys are the (lowercased) keywords and the values their validity
    def validate(graph, keywords)
      keywords = normalize_array(keywords).map{|k| k.gsub(',', '%2C')}
      search = graph.search(nil, type: 'adkeywordvalid', keyword_list: keywords.join(","))
      results = {}
      search.each do |r|
        results[r['name']] = r['valid']
      end
      results
    end

  end
end
