module Xup
  class Context

    attr_reader  :buffer,  :options

    def initialize(options={}, &block)
      @buffer, @options = "", options
      instance_eval &block if block_given?
    end

    def use(*modules)
      modules.each do |mod|
        extend mod
      end
    end

    def self.use(*modules)
      modules.each do |mod|
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
