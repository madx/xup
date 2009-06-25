# coding: utf-8
$KCODE = 'u' if RUBY_VERSION < "1.9"

module Xup
  module Modules; end
  module Document; end
end

%w[context].each do |lib|
  require File.join(File.dirname(__FILE__), 'xup', lib)
end
