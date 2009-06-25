# coding: utf-8
$KCODE = 'u' if RUBY_VERSION < "1.9"

module Xup; end

%w[context].each do |lib|
  require File.join(File.dirname(__FILE__), 'xup', lib)
end
