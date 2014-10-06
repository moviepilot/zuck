module Zuck

  # Including this module does three things:
  #
  # 1.  Lets you use `x[:foo]` to access keys of the
  #     underlying Hash
  # 2.  Lets you use `x[:foo] = :bar` to set values in
  #     the underlying Hash
  # 3.  Lets you define which keys are to be expected in
  #     the underlying hash. These keys will become methods
  #
  # Here's an example:
  #
  #     class MyObjectWithHash
  #
  #       include Zuck::HashDelegator
  #
  #       known_keys :foo, :bar
  #
  #       def initialize(initial_data)
  #         set_data(initial_data)
  #       end
  #     end
  #
  #     > x = MyObjectWithHash.new(foo: :foo)
  #     > x.foo
  #     => :foo
  #     > x.bar
  #     => nil
  #     > x['bar'] = :everything_is_a_symbol
  #     > x[:bar]
  #     => :everything_is_a_symbol
  #     > x['bar']
  #     => :everything_is_a_symbol
  #     > x.foo
  #     => :everything_is_a_symbol
  #     > x.foo = :you_also_have_setters
  #     => :you_also_have_setters
  #
  # As you can see, all string keys become symbols and the
  # foo and bar methods were added because they are known keys
  #
  module HashDelegator

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def known_keys(*args)
        if args.length > 0
          @known_keys = args
          args.each do |key|

            # Define list of known keys
            self.send(:define_method, :known_keys) do
              args || []
            end

            # Define getter
            self.send(:define_method, key) do
              init_hash
              @hash_delegator_hash[key]
            end

            # Define setter
            self.send(:define_method, "#{key}=") do |val|
              init_hash
              @hash_delegator_hash[key] = val
            end
          end
        else
          Array(@known_keys)
        end
      end
    end

    def set_data(d)
      e = "You can only assign a Hash to #{self.class}, not a #{d.class}"
      raise e unless d.is_a? Hash
      hash = Hash.new
      d.each do |key, value|
        hash[(key.to_sym rescue key) || key] = value
      end
      @hash_delegator_hash = hash
    end

    def data=(d)
      set_data(d)
    end

    def data
      @hash_delegator_hash
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
