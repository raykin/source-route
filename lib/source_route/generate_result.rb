module SourceRoute

  class GenerateResult

    Config = Struct.new(:format, :show_additional_attrs,
                        :include_local_var, :include_instance_var, :include_tp_self,
                        :filename, :import_return_to_call) do
      def initialize(f="silence", s=[], ilr=false, iiv=false)
        super(f, s, ilr, iiv)
      end
    end

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
      b_return: [:binding, :defined_class, :method_id, :return_value],
      thread_begin: [:defined_class, :method_id],
      thread_end: [:defined_class, :method_id]
    }

    def initialize(wrapper)
      @wrapper = wrapper

      @config = @wrapper.condition.result_config

      @tp_events = @wrapper.condition.events
    end

    def output_attributes(event)
      attrs = DEFAULT_ATTRS[event] + Array(@config.show_additional_attrs)
      attrs.push(:event) if @tp_events.size > 1
      attrs.uniq
    end

    def build(trace_point_instance)
      @tp = trace_point_instance
      collect_tp_data
      collect_tp_self if @config[:include_tp_self]
      collect_local_var_data if @config[:include_local_var]
      collect_instance_var_data if @config[:include_instance_var]
      @collect_data
    end

    def output(tp_ins)

      format = @config.format
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

    # include? will evaluate @tp.self, if @tp.self is AR::Relation, it could cause problems
    # So that's why I use object_id as replace
    def collect_tp_self
      unless @wrapper.tp_self_caches.map(&:object_id).include? @tp.self.object_id
        @wrapper.tp_self_caches.push @tp.self
      end
      @collect_data[:tp_self] = @wrapper.tp_self_caches.map(&:object_id).index(@tp.self.object_id)
    end

    def collect_tp_data
      @collect_data = output_attributes(@tp.event).inject({}) do |memo, key|
        memo[key.to_sym] = @tp.send(key) if @tp.respond_to?(key)
        memo
      end
    end

    def collect_local_var_data
      local_var_hash = {}

      # Warn: @tp.binding.eval('local_variables') =! @tp.binding.send('local_variables')
      @tp.binding.eval('local_variables').each do |v|
        local_var_hash[v] = @tp.binding.local_variable_get v
      end
      if local_var_hash != {}
        @collect_data.merge!(local_var: local_var_hash)
      end
    end

    def collect_instance_var_data
      instance_var_hash = {}
      @tp.self.instance_variables.each do |key|
        instance_var_hash[key] = @tp.self.instance_variable_get(key)
      end
      if instance_var_hash != {}
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

    def console_stack_overflow
      ap "#{@collect_data[:defined_class].inspect}##{@collect_data[:method_id]}"
    end

  end # END GenerateResult

end
