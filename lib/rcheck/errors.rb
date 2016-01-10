
module RCheck
  module Errors

    # abstract
    class Base < RuntimeError; end
    class State < Base; end
    class Argument < Base; end
    class Name < Argument; end

    # invalid arguments for invocation
    class InvocationName < Name; end

    # invalid arguments for invocation
    class NoSuchSuite < Name; end

    # invalid configuration parameter name
    class ConfigName < Name; end

    # invalid configuration parameter name
    class ConfigParam < Name; end

    # Tried to do something that requires an invocation
    class NoInvocation < State; end

    # tried to redefine suite after printing
    class SuiteRedefinition < State; end

    # tried to require same test more than once
    class ReRequire < State; end

    # tried to do something that requires assertions to be defined
    # before they were defined
    class NoAssertions < State; end
  end
end
