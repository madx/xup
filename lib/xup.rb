# coding: utf-8
$KCODE = 'u' if RUBY_VERSION < "1.9"

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

    def build(kind = self.class, &block)
      context = kind.new
      context.use *(class << self; self; end).included_modules
      concat context.tap {|c| c.instance_eval(&block) }.buffer
    end

    def build!(kind = self.class, &block)
      concat kind.new.tap {|c| c.instance_eval(&block) }.buffer
    end

    def concat(string)
      @buffer << string
    end

  end
end
