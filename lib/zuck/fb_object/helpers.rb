module Zuck
  module FbObject
    module Helpers

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
