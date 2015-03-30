module Zuck

  # Thrown when a keyword, country, gender etc. is not valid
  class InvalidSpecError    < RuntimeError; end
  class InvalidKeywordError < InvalidSpecError; end
  class InvalidCountryError < InvalidSpecError; end
  class InvalidGenderError  < InvalidSpecError; end
  class ParamsMissingError  < InvalidSpecError; end

  # FB ads api wants uppercase 2 digit iso country codes
  ISO_COUNTRY_CODES = %w{ AX AF AL DZ AS AD AO AI AQ AG AR
                          AM AW AU AT AZ BS BH BD BB BY BE
                          BZ BJ BM BT BO BA BW BV BR IO BN
                          BG BF BI KH CM CA CV KY CF TD CL
                          CN CX CC CO KM CD CG CK CR CI HR
                          CU CY CZ DK DJ DM DO EC EG SV GQ
                          ER EE ET FK FO FJ FI FR GF PF TF
                          GA GM GE DE GH GI GR GL GD GP GU
                          GT GN GW GY HT HM HN HK HU IS IN
                          ID IR IQ IE IL IT JM JP JO KZ KE
                          KI KP KR KW KG LA LV LB LS LR LY
                          LI LT LU MO MK MG MW MY MV ML MT
                          MH MQ MR MU YT MX FM MD MC MN MS
                          MA MZ MM NA NR NP NL AN NC NZ NI
                          NE NG NU NF MP NO OM PK PW PS PA
                          PG PY PE PH PN PL PT PR QA RE RO
                          RU RW SH KN LC PM VC WS SM ST SA
                          SN CS SC SL SG SK SI SB SO ZA GS
                          ES LK SD SR SJ SZ SE CH SY TW TJ
                          TZ TH TL TG TK TO TT TN TR TM TC
                          TV UG UA AE GB US UM UY UZ VU VA
                          VE VN VG VI WF EH YE ZM ZW }

  #
  # Some helpers around https://developers.facebook.com/docs/reference/ads-api/targeting-specs/
  # Use like this:
  #
  #     > ts = Facebook::TargetingSpec.new(graph, ad_account, interest: 'foo', geo_locations: {countries: ['US']})
  #     > ts.spec
  #     => {
  #        :countries => [
  #          [0] "US"
  #        ],
  #         :interests => [
  #          [0] "foo"
  #        ]
  #     }
  #     > ts.fetch_reach
  #     => 12345
  #
  class TargetingSpec
    include Zuck::Helpers

    attr_reader :spec, :graph

    # @param graph [Koala::Facebook::API] The koala graph object to use
    # @param ad_account [String] The ad account you want to use to query the facebook api
    # @param spec [Hash] The targeting spec. Supported keys:
    #
    #   - `:countries`: Array of uppercase two letter country codes
    #   - `:genders` (optional): Can be an array with 2 (female) and 1 (male)
    #   - `:gender` (optional): Set it to 'male' or 'female' to autoconfigure the genders array
    #   - `:age_min` (optional): In years
    #   - `:age_max` (optional): In years
    #   - `:age_class` (optional): Set it to `young` or `old` to autoconfigure `age_min` and `age_max`
    #     for people older or younger than 25
    #   - `:locales` (optional): [disabled] Array of integers, valid keys are here https://graph.facebook.com/search?type=adlocale&q=en
    #   - `:interests`: Array of strings with interests
    #
    def initialize(graph, ad_account, spec = nil)
      @validated_interests = {}
      @graph = graph
      @ad_account = normalize_account_id(ad_account)
      self.spec = spec
    end

    # @param spec [Hash] See {#initialize}
    def spec=(spec)
      @spec = spec || {}
      build_spec
    end

    # @return [Hash] The reach for the options given in {#initialize}, see
    #   https://developers.facebook.com/docs/reference/ads-api/reachestimate/
    def fetch_reach
      validate_spec
      json = @spec.to_json
      o = "#{@ad_account}/reachestimate"
      result = graph.get_object(o, targeting_spec: json)
      return false unless result
      result.with_indifferent_access
    end

    def validate_interests
      @spec[:interests].each do |w|
        raise(InvalidKeywordError, w) unless validate_interest(w)
      end
    end

    # Validates a single interest from the cache or calls
    # {TargetingSpec.validate_interests}.to validate the interests via
    # facebook's api.
    # @param interest [String] A single interest
    # @return boolean
    def validate_interest(interest)
      if @validated_interests[interest] == nil
        interests = [@spec[:interests]] + [interest]
        @validated_interests = Zuck::AdInterest.validate(@graph, interests)
      end
      @validated_interests[interest] == true
    end

    # Fetches a bunch of reach estimates from facebook at once.
    # @param graph Koala graph instance
    # @param specs [Array<Hash>] An array of specs as you would pass to {#initialize}
    # @return [Array<Hash>] Each spec you passed in as the requests parameter with
    #   the [:success] set to true/false and [:reach]/[:error] are filled respectively
    def self.batch_reaches(graph, ad_account, specs)

      # Make all requests
      reaches = []
      specs.each_slice(50) do |specs_slice|
        reaches += graph.batch do |batch_api|
          specs_slice.each do |spec|
            targeting_spec = Zuck::TargetingSpec.new(batch_api, ad_account, spec)
            targeting_spec.fetch_reach
          end
        end
      end

      # Structure results
      result = []
      reaches.each_with_index do |res, i|
        result[i] = specs[i].dup
        if res.class < StandardError
          result[i][:success] = false
          result[i][:error]   = res
        else
          result[i][:success] = true
          result[i][:reach]   = res.with_indifferent_access
        end
      end
      result
    end

    # Convenience method, parameters are the same as in {#initialize}
    # @return (see #initialize)
    def self.fetch_reach(graph, ad_account, options)
      ts = Zuck::TargetingSpec.new(graph, ad_account, options)
      ts.fetch_reach
    end

    private

    def validate_spec
      @spec[:interests] = @spec[:interests]
      # deprecated: https://developers.facebook.com/docs/apps/migrations/migration-2014-01-08
      # @spec[:broad_age] ||= false
      validate_countries
      unless @spec[:interests].present? or @spec[:connections].present?
        raise(ParamsMissingError, "Need to set :interests or :connections")
      end
    end

    def validate_countries
      return unless @spec[:geo_locations] and @spec[:geo_locations][:countries]
      @spec[:geo_locations][:countries] = normalize_countries(@spec[:geo_locations][:countries])
      self.class.valid_countries?(@spec[:geo_locations][:countries])
    end

    def self.valid_countries?(countries)
      raise(InvalidCountryError, "Need to set :countries") unless countries.present?
      raise(InvalidCountryError, "Must supply between 1 and 25 countries") if countries.length > 25
      invalid_countries = countries - Zuck::ISO_COUNTRY_CODES
      return if invalid_countries.empty?
      raise(InvalidCountryError, "Invalid countrie(s): #{invalid_countries}")
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
      @spec[:genders] = [2] if gender.to_s == 'female'

      interest = spec.delete(:interest)
      @spec[:interests] = [interest, @spec[:interests]].compact.flatten

      country = spec.delete(:country)
      @spec[:countries] = normalize_countries([country, @spec[:countries]])

      connections = spec.delete(:connections)
      @spec[:connections] = normalize_array([connections, @spec[:connections]])

    end

  end
end
