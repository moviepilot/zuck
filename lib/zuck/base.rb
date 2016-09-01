module Zuck
  class Base

    class << self

      def find(id)
        response = rest_get(id, query: default_query)
        new(response)
      end

      # HTTP wrappers

      def rest_get(path, query: {})
        hash = query.merge(access_token: Zuck.access_token)
        puts "GET #{url(path)} | #{hash.inspect}"
        parse HTTParty.get(url(path), query: hash).parsed_response
      end

      def rest_post(path, query: {})
        hash = query.merge(access_token: Zuck.access_token)
        puts "POST #{url(path)} | #{hash.inspect}"
        parse HTTParty.post(url(path), query: hash).parsed_response
      end

      def rest_upload(path, query: {})
        hash = query.merge(access_token: Zuck.access_token)
        puts "UPLOAD #{url(path)} | #{hash.inspect}"
        parse HTTMultiParty.post(url(path), query: hash, detect_mime_type: true).parsed_response
      end

      def default_query
        { fields: self::FIELDS.join(',') }
      end

      # pagination

      def paginate(response)
        data = response['data'].present? ? response['data'] : []

        while (paging = response['paging']).present? && (url = paging['next']).present?
          response = rest_get(url)
          data += response['data'] if response['data'].present?
        end

        data
      end

      private

      def url(path)
        path.first(4) == 'http' ? path : "#{Zuck.host}/#{path}"
      end

      def parse(response)
        response = response.is_a?(String) ? JSON.parse(response) : response

        if response['error'].present?
          raise Exception, "#{response['error']['code']}: #{response['error']['message']}"
        end

        response
      end

    end

    attr_accessor :data

    def initialize(data)
      self.data = data

      self.class::FIELDS.each do |field|
        if data.key?(field)
          send("#{field}=", data[field])
        end
      end
    end

    def rest_get(path, query: {}); self.class.rest_get(path, query: query) end
    def rest_post(path, query: {}); self.class.rest_post(path, query: query) end
    def rest_upload(path, query: {}); self.class.rest_upload(path, query: query) end

  end
end
