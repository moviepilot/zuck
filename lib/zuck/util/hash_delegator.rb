module Zuck
  module HashDelegator

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def known_keys(*args)
        args.each do |key|
          self.send(:define_method, key) do
            init_hash
            @hash_delegator_hash[key]
          end
        end
      end
    end

    def set_hash_delegator_data(d)
      e = "You can only assign a Hash to #{self.class}"
      raise e unless d.is_a? Hash
      @hash_delegator_hash = d.symbolize_keys
    end

    def [](key)
      init_hash
      @hash_delegator_hash[key.to_sym]
    end

    def []=(key, value)
      init_hash
      @hash_delegator_hash[key.to_sym] = value
    end

    def to_s
      init_hash
      vars = @hash_delegator_hash.map do |k, v|
        "#{k}: #{v.to_json}"
      end.join(", ")
      "#<#{self.class} #{vars}>"
    end

    private

    def init_hash
      @hash_delegator_hash ||= {}
    end

  end
end
