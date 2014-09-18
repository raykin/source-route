module SourceRoute

  class Wrapper
    include Singleton

    attr_accessor :conditions, :tp, :tp_caches, :tp_attrs_results
    attr_accessor :output_include_local_variables, :output_include_instance_variables

    def initialize
      reset
    end

    # output_format can be console, html
    def reset
      @tp.disable if @tp
      @conditions = OpenStruct.new(event: :call, negative: {}, positive: {},
                                   result_config: { output_format: 'none',
                                     selected_attrs: nil,
                                     include_local_var: false,
                                     include_instance_var: false
                                   })
      @tp_caches = []
      @tp_attrs_results = []
      self
    end

    # TODO: make event can be array
    def event(v)
      @conditions.event = v.to_sym unless v.nil?
    end

    def set_result_config(value)
      unless value.is_a? Hash
        conditions.result_config = value
      end
    end

    def output_format(data = nil, &block)
      conditions.result_config[:output_format] = if data.nil?
                                                   block
                                                 else
                                                   data
                                                 end
    end

    def selected_attrs(data)
      conditions.result_config[:selected_attrs] = [data].flatten
    end

    def output_include_local_variables
      conditions.result_config[:include_local_var] = true
    end

    def output_include_instance_variables
      conditions.result_config[:include_instance_var] = true
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
