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

    # @param graph [Koala::Facebook::API] The koala graph object to use
    # @param ad_account [String] The ad account you want to use to
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
      self.spec = spec if spec
    end

    # @param spec [Hash] See {#initialize}
    def spec=(spec)
      @spec = spec.symbolize_keys
      build_spec
    end

    # @return [Number] The reach for the options given in {#initialize}
    def fetch_reach
      begin
        validate_spec
        validate_keywords
        json = @spec.to_json
        o = "#{@ad_account}/reachestimate"
        result = graph.get_object(o, targeting_spec: json)
        return false unless result and result["users"].to_i >= 0
        result["users"].to_i
      rescue StandardError => e
        raise e if Rails.env == :test
        log_error(e)
        false
      end
    end

    # @return [Hash] The current targeting spec
    def spec
      @spec
    end

    # Hits the facebook ad api to check if a keyword is valid
    # @param keyword [String] The keyword you would like to check
    # @return [true, false]
    def validate_keyword(keyword)
      keyword = keyword.to_s
      if !@validated_keywords[keyword]
        result = graph.search(nil, type: 'adkeywordvalid', keyword_list: keyword.gsub(/,/, '%2C'))#  rescue []
        valid = result.first["valid"] == true rescue false
        @validated_keywords[keyword] = valid
      end
      @validated_keywords[keyword]
    end

    private

    def validate_keywords
      @spec[:keywords].each do |w|
        raise(InvalidKeywordError, w) unless validate_keyword(w)
      end
    end

    def graph
      @graph
    end

    def validate_spec
      @spec[:countries] = [@spec[:countries]].flatten.uniq.compact
      @spec[:keywords]  = [@spec[:keywords]].flatten.uniq.compact
      raise(InvalidCountryError, "Need to set :countries") unless @spec[:countries].present?
      unless @spec[:keywords].present? or @spec[:connections].present?
        raise(ParamsMissingError, "Need to set :keywords or :connections")
      end

    end

    def build_spec
      age = spec.delete(:age_class)
      if age.to_s == 'young'
        @spec[:age_min] = 13
        @spec[:age_max] = 24
      elsif age.to_s == 'old'
        @spec[:age_min] = 25
      else
        @spec[:age_min] = 13
      end

      gender = spec.delete(:gender)
      raise(InvalidGenderError, "Gender can only be male or female") if gender and !['male', 'female'].include?(gender.to_s)
      @spec[:genders] = [1] if gender.to_s == 'male'
      @spec[:genders] = [0] if gender.to_s == 'female'

      keyword = spec.delete(:keyword)
      @spec[:keywords] = [keyword, @spec[:keywords]].flatten.compact.uniq

      country = spec.delete(:country)
      @spec[:countries] = [country, @spec[:countries]].flatten.compact.uniq

      connections = spec.delete(:connections)
      @spec[:connections] = [connections, @spec[:connections]].flatten.compact.uniq

    end

  end
end
