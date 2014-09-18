module SourceRoute

  class TpResult

    DEFAULT_ATTRS = {
      call: [:defined_class, :event, :method_id],
      return: [:defined_class, :event, :method_id, :return_value]
    }

    def initialize(wrapper)
      @wrapper = wrapper

      @output_config = @wrapper.conditions.result_config

      @tp_event = @wrapper.conditions.event.to_sym
      if @output_config[:selected_attrs].nil? and [@wrapper.conditions.event].flatten.size == 1
        @output_config[:selected_attrs] = DEFAULT_ATTRS[@tp_event] - [:event]
      end
    end

    def build(trace_point_instance)
      @tp = trace_point_instance
      collect_tp_data
      collect_local_var_data
      collect_instance_var_data
      @collect_data
    end

    # always run build before it # not a good design
    def output

      format = @output_config[:output_format].to_sym

      case format
      when :none
        # do nothing
      when :console
        console_put
      when :html
        # I cant solve the problem: to generate html at the end,
        # I have to know when the application is end
      when :test
        # do nothing at now
      when :Proc
        # customize not defined yet
        # format.call(tp)
      else
        klass = "SourceRoute::Formats::#{format.to_s.capitalize}"
        ::SourceRoute.const_get(klass).render(self, trace_point_instance)
      end
    end

    private

    def collect_tp_data
      @collect_data = @output_config[:selected_attrs].inject({}) do |memo, key|
        memo[key.to_sym] = @tp.send(key) if @tp.respond_to?(key)
        memo
      end
    end

    def collect_local_var_data
      if @wrapper.conditions.result_config[:include_local_var]
        local_var_hash = {}

        @tp.binding.eval('local_variables').each do |v|
          local_var_hash[v] = @tp.binding.local_variable_get v
        end

        @collect_data.merge!(local_var: local_var_hash)
      end
    end

    def collect_instance_var_data
      if @wrapper.conditions.result_config[:include_instance_var]
        instance_var_hash = {}
        @tp.self.instance_variables.each do |key|
          instance_var_hash[key] = @tp.self.instance_variable_get(key)
        end
        @collect_data.merge!(instance_var: instance_var_hash)
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

  end # END TpResult

end
