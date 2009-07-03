# coding: utf-8
$KCODE = 'u' if RUBY_VERSION < "1.9"

module Xup
  module Modules #:nodoc:
  end
  module Document
  end

  def self.load(*mods)
    mods.each do |mod|
      require File.join(File.dirname(__FILE__), 'xup', 'modules', mod.to_s)
    end
  end

  def self.get_module(name)
    if Object.const_defined?(name)
      Object.const_get name
    elsif Modules.const_defined?(name)
      Modules.const_get name
    else
      raise NameError, "no such module #{name}"
    end
  end
end

%w[context].each do |lib|
  require File.join(File.dirname(__FILE__), 'xup', lib)
end
