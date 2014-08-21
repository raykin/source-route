module SourceRoute

  class Wrapper
    include Singleton

    attr_accessor :conditions, :tp_caches
    attr_accessor :output_include_local_variables, :output_include_instance_variables

    def initialize
      reset
    end

    def reset
      @conditions = OpenStruct.new event: :call, negative: {}, positive: {}, result_config: {output_format: nil}
      @tp_caches = []
    end

    # TODO: make event can be array
    def event(v)
      @conditions.event = v.to_sym unless v.nil?
    end

    def output_format(data = nil, &block)
      conditions.result_config[:output_format] = if data.nil?
                                                   block
                                                 else
                                                   [data].flatten
                                                 end
    end

    def output_include_local_variables(bool_value)
      conditions.result_config[:include_local_var] = bool_value
    end

    def output_include_instance_variables(bool_value)
      conditions.result_config[:include_instance_var] = bool_value
    end

    TRACE_POINT_METHODS = [:defined_class, :method_id, :path, :lineno]

    TRACE_POINT_METHODS.each do |m|
      define_method m do |v|
        @conditions.positive[m] = v
      end

      define_method "#{m}_not" do |v|
        @conditions.negative[m] = v
      end
    end

  end

end
