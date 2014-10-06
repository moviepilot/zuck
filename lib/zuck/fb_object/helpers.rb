module Zuck
  module FbObject
    module Helpers

      private

      def get(graph, path)
        begin
          ret = []
          graph_collection = graph.get_object(path, fields: known_keys.compact.join(','))
          loop do
            ret += graph_collection
            break if not graph_collection.paging['next']
            graph_collection = graph_collection.next_page
          end
          ret
        rescue => e
          puts "#{e} graph.get_object(#{path.to_json})" if in_irb?
          raise e
        end
      end

      def create_connection(graph, parent, connection, args = {}, opts = {})
        begin
          graph.put_connections(parent, connection, args, opts)
        rescue => e
          msg = "#{e} graph.put_connections(#{parent.to_json}, #{connection.to_json}, #{args.to_json}, #{opts.to_json})"
          puts msg if in_irb?
          raise e
        end
      end

      def post(graph, path, data, opts = {})
        begin
          graph.graph_call(path.to_s, data, "post", opts)
        rescue => e
          msg = "#{e} graph.graph_call(#{path.to_json}, #{data.to_json}, \"post\", #{opts.to_json})"
          puts msg if in_irb?
          raise e
        end
      end

      def delete(graph, path)
        begin
          graph.delete_object(path)
        rescue => e
          puts "#{e} graph.delete(#{path.to_json})" if in_irb?
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
        defined?(IRB)
      end
    end
  end
end
