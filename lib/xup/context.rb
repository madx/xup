module Xup
  # This is the main Xup class.
  #
  # Basically, a Context is an object that holds a buffer and an hash of
  # options. It also provides basic methods for manipulating the buffer and
  # building sub-contexts
  class Context

    attr_reader  :buffer,  :options

    def initialize(options={}, &block)
      @buffer, @options = "", options
      instance_eval &block if block_given?
    end

    def use(*modules)
      modules.each do |mod|
        if mod.kind_of?(String) or mod.kind_of?(Symbol)
          mod = Xup.get_module(mod)
        end
        extend mod
      end
    end

    def self.use(*modules)
      modules.each do |mod|
        if mod.kind_of?(String) or mod.kind_of?(Symbol)
          mod = Xup.get_module(mod)
        end
        send :include, mod
      end
    end

    def build(propagate=:inherit, kind=self.class, options={}, &block)
      options = @options.merge(options) if propagate == :inherit
      context = kind.new(options)
      if propagate == :inherit
        context.use *(class << self; self; end).included_modules
      end
      context.tap {|c| c.instance_eval(&block) }.buffer
    end

    def build!(propagate=:inherit, kind=self.class, options={}, &block)
      concat build(propagate, kind, options, &block)
    end

    def concat(string)
      @buffer << string.to_s
    end

  end
end
