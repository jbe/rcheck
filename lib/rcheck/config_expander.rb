
module RCheck
  module ConfigExpander
    def self.constantize(name)
      name.to_s.split('_').map(&:capitalize).join.to_sym
    end

    def self.[](name, value)
      return [] if value == :none
      case name
      when :colors    then parse_theme value
      when :progress  then to_instance(ProgressPrinters, *value)
      when :report    then to_instance(ReportPrinters,   *value)
      when :filter    then to_instance(BacktraceFilters, *value)
      else value
      end
    end

    def self.to_instance(scope, *list)
      list.map do |item|
        case item
        when Class  then item.new
        when Symbol then safer_const_get(scope, item)
        else item
        end
      end
    end

    def self.safer_const_get(scope, item)
      scope.const_get(constantize item).new
    rescue NameError
      raise Errors::ConfigParam, "#{item.inspect} not found in #{scope.inspect}"
    end

    def self.parse_theme(theme)
      return theme if theme.is_a?(Hash)
      name = :"#{theme.upcase}"
      if Colors::Themes.const_defined?(name)
        Colors::Themes.const_get(name)
      else
        raise "Invalid color theme: #{theme.inspect}"
      end
    end
  end
end
