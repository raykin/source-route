module SourceRoute

  #
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

      format = @output_config[:output_format].to_sym

      collect_data

      case format
      when Symbol
        case format
        when :console
          console_put
        when :html
          # I cant solve the problem: to generate html at the end,
          # I have to know when the application is end
        when :test
          # do nothing at now
        else
          klass = "SourceRoute::Formats::#{format.to_s.capitalize}"
          ::SourceRoute.const_get(klass).render(self)
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
        instance_var_hash = {}
        @tp.self.instance_variables.each do |key|
          instance_var_hash[key] = @tp.self.instance_variable_get(key)
        end
        @collect_data.last.merge!(instance_var: instance_var_hash)
      end
    end

    def console_put
      ap @collect_data
    end

  end

end
