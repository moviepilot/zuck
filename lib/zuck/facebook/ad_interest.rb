module Zuck
  module AdInterest
    extend Zuck::Helpers
    extend self

    # Given an interest, make a guess on what the closest interest
    # on the facebook ads api is. It tends to use a # prefixed
    # interest if available, and also a more popular one over a less
    # popular one
    def best_guess(graph, interest)
      search(graph, interest).sort do |a,b|
        if a[:audience].to_i > 0 || b[:audience].to_i > 0
          a[:audience].to_i <=> b[:audience].to_i
        else
          b[:interest].length <=> a[:interest].length
        end
      end.last
    end

    # Checks the ad api to see if the given interests are valid
    # @return [Hash] The keys are the (lowercased) interests and the values their validity
    def validate(graph, interests)
      interests = normalize_array(interests).map{|k| k.gsub(',', '%2C')}
      search = graph.search(nil, type: 'adinterestvalid', interest_list: [interests].flatten)
      results = {}
      search.each do |r|
        results[r['name']] = r['valid']
      end
      results
    end

    # Ad interest search
    def search(graph, interest)
      results = graph.search(interest, type: :adinterest).map do |r|
        {
          interest: r['name'],
          id:   r['id'],
          audience: r['audience_size']
        }
      end
    end
  end

end
