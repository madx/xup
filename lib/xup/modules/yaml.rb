require 'yaml'

module Xup
  module Modules

    # The YAML module provides two methods that dump their parameter as
    # a YAML document. Use them like you would use YAML.dump(obj)
    #
    # == Example
    #
    #   Xup::Context.new {
    #     use Xup::Modules::YAML
    #     yaml [1,2,3]
    #   }.buffer # => "--- \n- 1\n- 2\n- 3\n"
    module YAML

      # Returns a YAML dump of <tt>obj</tt>
      def yaml(obj)
        ::YAML.dump(obj)
      end

      # Concats a YAML dump of <tt>obj</tt> to the buffer
      def yaml!(obj)
        concat ::YAML.dump(obj)
      end
    end
  end
end
