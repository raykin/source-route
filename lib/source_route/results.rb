module SourceRoute

  # No Test Yet
  class Results

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

    def output(trace_point_instance)

      @tp = trace_point_instance

      format = @output_config[:output_format]

      collect_data

      case format
      when String
        case format.to_sym
        when :console
          console_put
        when :html
          # not implemented yet
        when :test
          # do nothing at now
        else
        end
      when Proc
        format.call(tp)
      else
      end

      @collect_data
    end

    private

    def collect_data
      collect_tp_data
      @collect_data.push({})
      collect_local_var_data
      collect_instance_var_data
      @collect_data.pop if @collect_data.last == {}
    end

    def collect_tp_data
      @collect_data = @output_config[:selected_attrs].map do |key|
        @tp.respond_to?(key) ? @tp.send(key) : nil
      end
    end

    def collect_local_var_data
      if @wrapper.conditions.result_config[:include_local_var]
        local_var_hash = {}

        @tp.binding.eval('local_variables').each do |v|
          local_var_hash[v] = @tp.binding.local_variable_get v
        end

        @collect_data.last.merge!(local_var: local_var_hash)
      end
    end

    def collect_instance_var_data
      if @wrapper.conditions.result_config[:include_instance_var]
        # Not implement yet
      end
    end

    def console_put
      ap @collect_data
    end

  end

end
