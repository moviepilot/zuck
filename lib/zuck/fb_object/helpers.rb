module Zuck
  module FbObject
    module Helpers

      private

      def get(graph, path)
        begin
          graph.get_object(path)
        rescue => e
          puts "#{e} graph.get_object(#{path.to_json})"
          raise e
        end
      end

      def create_connection(graph, parent, connection, args = {}, opts = {})
        begin
          graph.put_connections(parent, connection, args, opts)
        rescue => e
          puts "#{e} graph.put_connections(#{parent.to_json}, #{connection.to_json}, #{args.to_json}, #{opts.to_json})"
          raise e
        end
      end

      def post(graph, path, data, opts = {})
        begin
          graph.graph_call(path.to_s, data, "post", opts)
        rescue => e
          puts "#{e} graph.graph_call(#{path.to_json}, #{data.to_json}, \"post\", #{opts.to_json})"
          raise e
        end
      end

      def delete(graph, path)
        begin
          graph.delete_object(path)
        rescue => e
          puts "#{e} graph.delete(#{path.to_json})"
          raise e
        end
      end

      def path_with_parent(parent=nil)
        paths = []
        paths << parent.path if parent
        paths << list_path
        paths.join('/')
      end
    end
  end
end
