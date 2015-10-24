
module RCheck
  module Errors

    # abstract
    class Base < RuntimeError; end
    class State < Base; end
    class Argument < Base; end
    class Name < Argument; end

    # invalid arguments for invocation
    class InvocationName < Name; end

    # invalid configuration parameter name
    class ConfigName < Name; end

    # invalid configuration parameter name
    class ConfigParam < Name; end

    # tried to redefine suite after printing
    class SuiteNotOpen < State; end
  end
end
