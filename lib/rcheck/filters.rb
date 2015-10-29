module RCheck
  module Filters
    def self.port_regex(str)
      Regexp.new(str.gsub("/", File::SEPARATOR))
    end

    InstalledGems = port_regex('/lib\d*/ruby/')
    Executables   = port_regex('bin/')
    Rcheck        = port_regex('lib/rcheck')
    Jruby         = port_regex('org/jruby/')

    def self.gem(name)
      sep = File::SEPARATOR
      /#{sep}#{name}(-[^#{sep}]+)?#{sep}/
    end

    module Anti
      Cwd = Regexp.new(Dir.getwd)
    end
  end
end
