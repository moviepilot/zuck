module Zuck
  module Helpers
    def normalize_array(arr)
      [arr].flatten.compact.uniq.sort
    end

    def normalize_countries(countries)
      normalize_array(countries).map(&:upcase)
    end

    def values_from_string_or_object_interests(interests)
      [interests].flatten.map do |interest|
        if interest.is_a?(String)
          interest
        else
          interest[:name] || interest['name']
        end
      end
    end
  end
end
