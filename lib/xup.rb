# coding: utf-8
$KCODE = 'u' if RUBY_VERSION < "1.9"

module Xup #:nodoc:
  module Modules #:nodoc: all
  end
  module Document #:nodoc: all
  end
end

%w[context].each do |lib|
  require File.join(File.dirname(__FILE__), 'xup', lib)
end
