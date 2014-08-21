module SourceRoute

  # No Test Yet
  class Results

    DEFAULT_FORMAT = {
      call: [:defined_class, :event, :method_id],
      return: [:defined_class, :event, :method_id, :return_value]
    }

    def initialize(wrapper)
      @wrapper = wrapper

      @format = wrapper.conditions.result_config[:output_format]

      if @format.nil? and [wrapper.conditions.event].flatten.size == 1
        @format = DEFAULT_FORMAT[wrapper.conditions.event.to_sym] - [:event]
      end

      @include_local_var = wrapper.conditions.result_config[:include_local_var]
      @include_instance_var = wrapper.conditions.result_config[:include_instance_var]
    end

    def output(trace_point_instance)

      tp = trace_point_instance

      # format either defined by user or cached when only trace one event
      if defined? @format
        format = @format
      else
        format = Results::DEFAULT_FORMAT[@wrapper.conditions.event]
      end

      if format.is_a? Array
        v = format.map do |key|
          tp.respond_to?(key) ? tp.send(key) : nil
        end

        # try add binging output here
        # puts tp.binding.eval('local_variables')

        # # byebug

        # # puts tp.self.send('local_variables')

        # TODO: add {params: value} format
        # tp.binding.eval('local_variables').each do |v|
        #   ap tp.binding.local_variable_get v
        # end

        # ap v

        ap v
      elsif format.is_a? Proc
        format.call(tp)
      end

    end

  end

end
