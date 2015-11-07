
module RCheck
  module ConfigExpander
    def self.constantize(name)
      name.to_s.split('_').map(&:capitalize).join.to_sym
    end

    def self.[](name, value)
      return [] if value == :none
      case name
      when :colors       then parse_theme value
      when :files        then parse_string_array value
      when :progress     then to_instance(ProgressPrinters, *value)
      when :report       then to_instance(ReportPrinters,   *value)
      when :filters      then to_instance(Filters,          *value)
      when :anti_filters then to_instance(Filters::Anti,    *value)
      when :headers      then to_instance(Headers,          *value)
      when :seed, :fail_code, :success_code
        value.to_s.to_i
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
      if scope.const_defined?(constantize item)
        val = scope.const_get(constantize item)
        val.respond_to?(:new) ? val.new : val
      else
        raise Errors::ConfigParam, "#{item.inspect} not found in #{scope.inspect}"
      end
    end

    def self.parse_string_array(value)
      Array(value).map(&:to_s)
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
