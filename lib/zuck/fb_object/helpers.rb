module Zuck
  module FbObject
    module Helpers

      private
      MAX_RETRIES = 3
      RETRY_DELAY_SECONDS = 3
      
      def get(graph, path)
        num_retries = 0
        response = nil
        begin
          response = graph.get_object(path, fields: known_keys.compact.join(','))
        rescue => e
          num_retries+=1
          if e.instance_of?(Koala::Facebook::ServerError) && num_retries<MAX_RETRIES
            Rails.logger.warn "#{self.class.name} | get failed for #{path} (attempts: #{num_retries}, message: #{e})"
            sleep(RETRY_DELAY_SECONDS)
            retry
          else
            Rails.logger.warn "#{self.class.name} | #{e} for graph.get_object(#{path.to_json})"
            raise e
          end
        end
        # Rails.logger.info "#{self.class.name} | GET | #{response.inspect}"
        return response
      end

      def create_connection(graph, parent, connection, args = {}, opts = {})
        num_retries = 0
        response = nil
        begin
          response = graph.put_connections(parent, connection, args, opts)
        rescue => e
          num_retries+=1
          if e.instance_of?(Koala::Facebook::ServerError) && num_retries<MAX_RETRIES
            Rails.logger.warn "#{self.class.name} | put failed for #{path} (attempts: #{num_retries}, message: #{e})"
            sleep(RETRY_DELAY_SECONDS)
            retry
          else
            msg = "#{e} graph.put_connections(#{parent.to_json}, #{connection.to_json}, #{args.to_json}, #{opts.to_json})"
            Rails.logger.warn "#{self.class.name} | #{msg}"
            raise e
          end
        end
        # Rails.logger.info "#{self.class.name} | PUT | #{response.inspect}"
        return response
      end

      def post(graph, path, data, opts = {})
        num_retries = 0
        response = nil
        begin
          response = graph.graph_call(path.to_s, data, "post", opts)
        rescue => e
          num_retries+=1
          # Temp logging for POST requests
          if e.instance_of?(Koala::Facebook::ServerError) && num_retries<MAX_RETRIES
            Rails.logger.warn "#{self.class.name} | post failed for #{path} (attempts: #{num_retries}, message: #{e})"
            sleep(RETRY_DELAY_SECONDS)
            retry
          else
            msg = "#{e} graph.graph_call(#{path.to_json}, #{data.to_json}, \"post\", #{opts.to_json})"
            Rails.logger.warn "#{self.class.name} | #{msg}"
            raise e
          end
        end
        # Rails.logger.info "#{self.class.name} | POST | #{response.inspect}"
        return response
      end

      def delete(graph, path)
        num_retries = 0
        response = nil
        begin
          response = graph.delete_object(path)
        rescue => e
          num_retries+=1
          if e.instance_of?(Koala::Facebook::ServerError) && num_retries<MAX_RETRIES
            Rails.logger.warn "#{self.class.name} | delete failed for #{path} (attempts: #{num_retries}, message: #{e})"
            sleep(RETRY_DELAY_SECONDS)
            retry
          else
            Rails.logger.warn "#{self.class.name} | #{e} graph.delete(#{path.to_json})"
            raise e
          end
        end
        # Rails.logger.info "#{self.class.name} | DELETE | #{response.inspect}"
        return response
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
