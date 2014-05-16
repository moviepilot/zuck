module Zuck
  module FbObject
    module Helpers

      private
      MAX_RETRIES = 3
      RETRY_DELAY_SECONDS = 3
      
      def get(graph, path)
        num_retries = 0
        begin
          graph.get_object(path, fields: known_keys.compact.join(','))
        rescue => e
          num_retries+=1
          if e.instance_of? Koala::Facebook::ServerError && num_retries<MAX_RETRIES
            puts "get failed for #{path} (attempts: #{num_retries}, message: #{e})" if in_irb?
            sleep(RETRY_DELAY_SECONDS)
            retry
          else
            puts "#{e} graph.get_object(#{path.to_json})" if in_irb?
            raise e
          end
        end
      end

      def create_connection(graph, parent, connection, args = {}, opts = {})
        num_retries = 0
        begin
          graph.put_connections(parent, connection, args, opts)
        rescue => e
          num_retries+=1
          if e.instance_of? Koala::Facebook::ServerError && num_retries<MAX_RETRIES
            puts "create_connection failed (attempts: #{num_retries}, message: #{e})" if in_irb?
            sleep(RETRY_DELAY_SECONDS)
            retry
          else
            msg = "#{e} graph.put_connections(#{parent.to_json}, #{connection.to_json}, #{args.to_json}, #{opts.to_json})"
            puts msg if in_irb?
            raise e
          end
        end
      end

      def post(graph, path, data, opts = {})
        num_retries = 0
        begin
          graph.graph_call(path.to_s, data, "post", opts)
        rescue => e
          num_retries+=1
          if e.instance_of? Koala::Facebook::ServerError && num_retries<MAX_RETRIES
            "post failed for #{path} (attempts: #{num_retries}, message: #{e})" if in_irb?
            sleep(RETRY_DELAY_SECONDS)
            retry
          else
            msg = "#{e} graph.graph_call(#{path.to_json}, #{data.to_json}, \"post\", #{opts.to_json})"
            puts msg if in_irb?
            raise e
          end
        end
      end

      def delete(graph, path)
        num_retries = 0
        begin
          graph.delete_object(path)
        rescue => e
          num_retries+=1
          if e.instance_of? Koala::Facebook::ServerError && num_retries<MAX_RETRIES
            "delete failed for #{path} (attempts: #{num_retries}, message: #{e})" if in_irb?
            sleep(RETRY_DELAY_SECONDS)
            retry
          else
            puts "#{e} graph.delete(#{path.to_json})" if in_irb?
            raise e
          end
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
