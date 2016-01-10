module RCheck
  module Conf
    def self.[](name)
      Command.active[name]
    end

    def self.valid_name?(param)
      !Command.find(:_base).read(param).nil?
    end
  end
end
