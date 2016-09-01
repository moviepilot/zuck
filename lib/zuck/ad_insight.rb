module Zuck
  class AdInsight < Base

    FIELDS = %w(ad_id objective impressions unique_actions cost_per_unique_action_type clicks cpc cpm ctr spend)
    attr_accessor *FIELDS

    class << self
      def get(graph_object_id:, range:, level: :ad, fields: FIELDS)
        resource_url = "#{rest_host}/#{graph_object_id}/insights"
        query = {
          access_token: Zuck.access_token,
          level: level,
          fields: fields.join(','),
          time_increment: 1,
          time_range: { 'since': range.first.to_s, 'until': range.last.to_s }
        }

        ad_performances = []
        errors = 0

        while resource_url.present? && errors < 10 # Page through and pull all the information into a single array.
          puts "GET #{resource_url} #{query.inspect}"
          insights = HTTParty.get(resource_url, query: query).parsed_response

          # Allow a few errors.
          if insights['error'].present?
            errors += 1
            puts insights.inspect
            sleep 2**errors
            next
          end

          if insights['data'].present? && insights['data'].is_a?(Array)
            ad_performances += insights['data']
          else
            puts insights.inspect
          end

          resource_url = insights['paging'].present? ? insights['paging']['next'] : nil
          query = nil
        end

        ad_performances
      end
    end

  end
end
