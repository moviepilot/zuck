module Zuck
  module Helpers

    # Facebook returns 'account_ids' without the 'act_' prefix,
    # so we have to treat account_ids special and make sure they
    # begin with act_
    def normalize_account_id(id)
      return id if id.to_s.start_with?('act_')
      "act_#{id}"
    end

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
