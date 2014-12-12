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
        if a[:audience_size].to_i > 0 || b[:audience_size].to_i > 0
          a[:audience_size].to_i <=> b[:audience_size].to_i
        else
          b[:name].length <=> a[:name].length
        end
      end.last
    end

    # Checks the ad api to see if the given interests are valid. You can either
    # pass it an array of strings, or an array of hashes with `:name` and `:id` keys.
    # @return [Hash] The keys are the (lowercased) interests and the values their validity
    def validate(graph, interests)
      results = {}
      normalized = normalize_array(values_from_string_or_object_interests(interests))
      normalized.each do |interest|
        # The interest is valid if we found at least one match that
        # has the exactly the same name (ignoring case)
        hits = search(graph, interest).select{|d| d['name'].downcase == interest.downcase}
        results[interest] = hits.count > 0
      end
      results
    end

    # Ad interest search
    def search(graph, interest)
      graph.search(interest, type: :adinterest).map(&:with_indifferent_access)
    end
  end

end
