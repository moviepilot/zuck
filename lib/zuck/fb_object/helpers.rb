module Zuck
  module FbObject
    module Helpers

      def rest_get(path, query: {})
        hash = query.merge(access_token: Zuck.graph.access_token)
        puts "GET #{rest_path}/#{path} | #{hash.inspect}"
        r = HTTParty.get("#{rest_path}/#{path}", query: hash).parsed_response
        puts "#{r.class.name}: #{r.inspect}"
        r.is_a?(String) ? JSON.parse(r) : r
      end

      def rest_post(path, query: {})
        hash = query.merge(access_token: Zuck.graph.access_token)
        puts "POST #{rest_path}/#{path} | #{hash.inspect}"
        r = HTTParty.post("#{rest_path}/#{path}", query: hash).parsed_response
        puts "#{r.class.name}: #{r.inspect}"
        r.is_a?(String) ? JSON.parse(r) : r # https://rollbar.com/Tophatter/Tophatter/items/12182/
      end

      def rest_upload(path, query: {})
        hash = query.merge(access_token: Zuck.graph.access_token)
        puts "UPLOAD #{rest_path}/#{path} | #{hash.inspect}"
        r = HTTMultiParty.post("#{rest_path}/#{path}", query: hash, detect_mime_type: true).parsed_response
        puts "#{r.class.name}: #{r.inspect}"
        r.is_a?(String) ? JSON.parse(r) : r
      end

      def rest_host
        'https://graph.facebook.com'
      end

      def rest_relative_path
        Koala.config.api_version
      end

      def rest_path
        "#{rest_host}/#{rest_relative_path}"
      end

      private

      def get(graph, path)
        puts "graph.get_object(#{path.to_json})" if in_irb?
        begin
          graph.get_object(path, fields: known_keys.compact.join(','), limit: 50000)
        rescue => e
          raise e
        end
      end

      def create_connection(graph, parent, connection, args = {}, opts = {})
        puts "graph.put_connections(#{parent.to_json}, #{connection.to_json}, #{args.to_json}, #{opts.to_json})" if in_irb?
        begin
          graph.put_connections(parent, connection, args, opts)
        rescue => e
          raise e
        end
      end

      def post(graph, path, data, opts = {})
        puts "graph.graph_call(#{path.to_json}, #{data.to_json}, \"post\", #{opts.to_json})" if in_irb?
        begin
          graph.graph_call(path.to_s, data, "post", opts)
        rescue => e
          raise e
        end
      end

      def delete(graph, path)
        puts "graph.delete(#{path.to_json})" if in_irb?
        begin
          graph.delete_object(path)
        rescue => e
          raise e
        end
      end

      def path_with_parent(parent=nil)
        paths = []
        paths << parent.path if parent
        paths << list_path
        paths.join('/')
      end

      def in_irb?
        defined?(IRB) || ($0.present? && $0.include?('console'))
      end

    end
  end
end
