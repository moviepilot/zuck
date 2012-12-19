module Zuck

  # Thrown when a keyword, country, gender etc. is not valid
  class InvalidSpecError    < RuntimeError; end
  class InvalidKeywordError < InvalidSpecError; end
  class InvalidCountryError < InvalidSpecError; end
  class InvalidGenderError  < InvalidSpecError; end
  class ParamsMissingError  < InvalidSpecError; end



  #
  # Some helpers around https://developers.facebook.com/docs/reference/ads-api/targeting-specs/
  # Use like this:
  #
  #     > ts = Facebook::TargetingSpec.new(graph, ad_account, keyword: 'foo', countries: ['US'])
  #     > ts.spec
  #     => {
  #        :countries => [
  #          [0] "US"
  #        ],
  #         :keywords => [
  #          [0] "foo"
  #        ]
  #     }
  #     > ts.fetch_reach
  #     => 12345
  #
  class TargetingSpec
    attr_reader :spec, :graph

    # @param graph [Koala::Facebook::API] The koala graph object to use
    # @param ad_account [String] The ad account you want to use to
    # @param user [User] The user who's ad account you want to use to
    #   query the facebook api
    # @param spec [Hash] The targeting spec. Supported keys:
    #
    #   - `:countries`: Array of uppercase two letter country codes
    #   - `:genders` (optional): Can be an array with 0 (female) and 1 (male)
    #   - `:gender` (optional): Set it to 'male' or 'female' to autoconfigure the genders array
    #   - `:age_min` (optional): In years
    #   - `:age_max` (optional): In years
    #   - `:age_class` (optional): Set it to `young` or `old` to autoconfigure `age_min` and `age_max`
    #     for people older or younger than 25
    #   - `:locales` (optional): [disabled] Array of integers, valid keys are here https://graph.facebook.com/search?type=adlocale&q=en
    #   - `:keywords`: Array of strings with keywords
    #
    def initialize(graph, ad_account, spec = nil)
      @validated_keywords = {}
      @graph = graph
      @ad_account = ad_account
      self.spec = spec
    end

    # @param spec [Hash] See {#initialize}
    def spec=(spec)
      @spec = spec
      build_spec
    end

    # @return [Number] The reach for the options given in {#initialize}
    def fetch_reach
      validate_spec
      validate_keywords
      json = @spec.to_json
      o = "#{@ad_account}/reachestimate"
      result = graph.get_object(o, targeting_spec: json)
      return false unless result and result["users"].to_i >= 0
      result["users"].to_i
    end

    # Validates a single keyword from the cache or calls
    # {TargetingSpec.validate_keywords}.to validate the keywords via
    # facebook's api.
    # @param keyword [String] A single keyword (will be downcased)
    # @return boolean
    def validate_keyword(keyword)
      if @validated_keywords[keyword] == nil
        keywords = normalize_array([@spec[:keywords]] + [keyword])
        @validated_keywords = self.class.validate_keywords(@graph, keywords)
      end
      @validated_keywords[keyword] == true
    end

    # Checks the ad api to see if the given keywords are valid
    # @return [Hash] The keys are the (lowercased) keywords and the values their validity
    def self.validate_keywords(graph, keywords)
      keywords = normalize_array(keywords).map{|k| k.gsub(',', '%2C')}
      search = graph.search(nil, type: 'adkeywordvalid', keyword_list: keywords.join(","))
      results = {}
      search.each do |r|
        results[r['name'].downcase] = r['valid']
      end
      results
    end

    # Fetches a bunch of reach estimates from facebook at once.
    # @param graph Koala graph instance
    # @param requests [Array<Hash>] An array of specs as you would pass
    #   to {#initialize}
    # @return [Array]
    def self.batch_process(graph, requests)
      responses = []
      requests.each_slice(50) do |requests_slice|
        graph.batch do |batch_api|
          requests_slice.each do |spec|
            targeting_spec = Zuck::TargetingSpec.new(graph, spec)
            responses << targeting_spec.batch_fetch_reach(batch_api)
          end
        end
      end
      result = []
      responses.each_with_index do |res, index|
        next if res.class < StandardError
        result << res.merge(requests[index])
      end
      result
    end

    private

    def self.normalize_array(arr)
      [arr].flatten.compact.map(&:to_s).map(&:downcase).uniq.sort
    end

    def normalize_array(arr)
      self.class.normalize_array(arr)
    end

    def validate_keywords
      @spec[:keywords].each do |w|
        raise(InvalidKeywordError, w) unless validate_keyword(w)
      end
    end

    def validate_spec
      @spec[:countries] = normalize_array(@spec[:countries])
      @spec[:keywords]  = normalize_array(@spec[:keywords])
      raise(InvalidCountryError, "Need to set :countries") unless @spec[:countries].present?
      unless @spec[:keywords].present? or @spec[:connections].present?
        raise(ParamsMissingError, "Need to set :keywords or :connections")
      end

    end

    def build_spec
      return unless @spec
      age = @spec.delete(:age_class)
      if age.to_s == 'young'
        @spec[:age_min] = 13
        @spec[:age_max] = 24
      elsif age.to_s == 'old'
        @spec[:age_min] = 25
      else
        @spec[:age_min] = 13
      end

      gender = spec.delete(:gender)
      if gender and !['male', 'female'].include?(gender.to_s)
        raise(InvalidGenderError, "Gender can only be male or female")
      end
      @spec[:genders] = [1] if gender.to_s == 'male'
      @spec[:genders] = [0] if gender.to_s == 'female'

      keyword = spec.delete(:keyword)
      @spec[:keywords] = normalize_array([keyword, @spec[:keywords]])

      country = spec.delete(:country)
      @spec[:countries] = normalize_array([country, @spec[:countries]])

      connections = spec.delete(:connections)
      @spec[:connections] = normalize_array([connections, @spec[:connections]])

    end

  end
end
