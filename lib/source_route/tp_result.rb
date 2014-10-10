module SourceRoute

  class TpResult

    # see event description in TracePoint API Doc
    DEFAULT_ATTRS = {
      call: [:defined_class, :method_id],
      return: [:defined_class, :method_id, :return_value],
      c_call: [:defined_class, :method_id],
      line: [:path, :lineno],
      # following are not tested yet
      class: [:defined_class],
      end: [:defined_class],
      c_return: [:defined_class, :method_id, :return_value],
      raise: [:raised_exception],
      b_call: [:binding, :defined_class, :method_id],
      b_return: [:binding, :defined_class, :method_id],
      thread_begin: [:defined_class, :method_id],
      thread_end: [:defined_class, :method_id]
    }

    def initialize(wrapper)
      @logger = Logger.new(STDOUT)
      @wrapper = wrapper

      @output_config = @wrapper.condition.result_config

      @tp_events = @wrapper.condition.events
      if @tp_events.length > 1 and @output_config[:selected_attrs]
        @logger.warn 'selected_attrs was ignored, cause watched event was more than one '
        @output_config[:selected_attrs] = nil
      end
    end

    def output_attributes(event)
      attrs = @output_config[:selected_attrs] || DEFAULT_ATTRS[event]
      attrs.push(:event) if @tp_events.size > 1
      attrs
    end

    def build(trace_point_instance)
      @tp = trace_point_instance
      collect_tp_data
      collect_local_var_data
      collect_instance_var_data
      @collect_data
    end

    def output(tp_ins)

      format = @output_config[:output_format]
      format = format.to_sym if format.respond_to? :to_sym

      case format
      when :none
        # do nothing
      when :console # need @collect_data
        console_put
      when :html
        # I cant solve the problem: to generate html at the end,
        # I have to know when the application is end
      when :test, :silence
        # do nothing at now
      when :stack_overflow
        console_stack_overflow
      when Proc
        format.call(tp_ins)
      else
        klass = "SourceRoute::Formats::#{format.to_s.capitalize}"
        ::SourceRoute.const_get(klass).render(self, tp_ins)
      end
    end

    private

    def collect_tp_data
      @collect_data = output_attributes(@tp.event).inject({}) do |memo, key|
        memo[key.to_sym] = @tp.send(key) if @tp.respond_to?(key)
        memo
      end
    end

    def collect_local_var_data
      if @wrapper.condition.result_config[:include_local_var]
        local_var_hash = {}

        @tp.binding.eval('local_variables').each do |v|
          local_var_hash[v] = @tp.binding.local_variable_get v
        end
        if local_var_hash != {}
          @collect_data.merge!(local_var: local_var_hash)
        end
      end
    end

    def collect_instance_var_data
      if @wrapper.condition.result_config[:include_instance_var]
        instance_var_hash = {}
        @tp.self.instance_variables.each do |key|
          instance_var_hash[key] = @tp.self.instance_variable_get(key)
        end
        if instance_var_hash != {}
          @collect_data.merge!(instance_var: instance_var_hash)
        end
      end
    end

    def console_put
      ret = []
      ret << "#{@collect_data[:defined_class].inspect}##{@collect_data[:method_id]}"
      left_values = @collect_data.reject { |k, v| %w[defined_class method_id].include? k.to_s }
      unless left_values == {}
        ret << left_values
      end
      ap ret
    end

    def console_stack_overflow
      ap "#{@collect_data[:defined_class].inspect}##{@collect_data[:method_id]}"
    end
  end # END TpResult

end
