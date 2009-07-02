$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'xup'
require 'bacon'

module Bacon
  module RedGreenOutput
    def handle_specification(name)
      yield
    end

    def handle_requirement(description)
      error = yield
      if error.empty?
        print "\e[32m.\e[0m"
      else
        if error == "FAILED"
          print "\e[31mF\e[0m"
        else
          print "\e[35mE\e[0m"
        end
      end
    end

    def handle_summary
      puts
      print ErrorLog if Backtraces
      puts "%d specifications (%d requirements), %d failures, %d errors" %
        Counter.values_at(:specifications, :requirements, :failed, :errors)
    end
  end
end
