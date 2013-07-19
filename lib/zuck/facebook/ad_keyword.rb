module Zuck
  module AdKeyword
    extend Zuck::Helpers
    extend self

    # Given a keyword, make a guess on what the closest keyword
    # on the facebook ads api is. It tends to use a # prefixed
    # keyword if available, and also a more popular one over a less
    # popular one
    def best_guess(graph, keyword)
      search(graph, keyword).sort do |a,b|
        if a[:audience].to_i > 0 || b[:audience].to_i > 0
          a[:audience].to_i <=> b[:audience].to_i
        else
          b[:keyword].length <=> a[:keyword].length
        end
      end.last
    end

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

    # Ad keyword search
    def search(graph, keyword)
      results = graph.search(keyword, type: :adkeyword).map do |r|
        audience = r['description'].scan(/[0-9]+/).join('').to_i rescue nil
        {
          keyword: r['name'],
          id:   r['id'],
          audience: audience
        }
      end
    end
  end

end
