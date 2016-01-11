module SourceRoute
  # what solution is good for summarize attrs that required to be included
  class TpResult
    # attrs from TracePoint object
    TP_ATTRS = [:event, :defined_class, :event, :lineno, :method_id,
                :path, :raised_exception, :return_value].freeze
    attr_accessor *TP_ATTRS

    # attrs generated from TracePoint.binding
    INNER_ATTRS = [:local_var, :instance_var, :params_var].freeze
    attr_accessor *INNER_ATTRS

    # customized attrs for build html output
    CUSTOM_ATTRS = [:order_id, :parent_ids, :direct_child_order_ids,
                   :has_return_value, :parent_length, :tp_self_refer].freeze
    attr_accessor *CUSTOM_ATTRS

    # The tricky part is
    # can't call method on @tp_ins outside trace block finished
    # it could be a security limitation in ruby TracePoint object
    # so collect_required_data can only run once and immediately
    def initialize(tp_ins)
      @tp_ins = tp_ins
      collect_required_data
    end

    def found_opposite
      @opposite_exist = true
    end

    def locate_opposite?
      @opposite_exist
    end

    def return_event?
      event == :return
    end

    def call_event?
      event == :call
    end

    def ==(other)
      tp_self_refer == other.tp_self_refer and method_id == other.method_id and
        defined_class == other.defined_class
    end

    def matched?
      @matched
    end

    def return_tp_assign_call_tp(call_tp)
      @matched = true
      call_tp.return_value = return_value
      call_tp.local_var = local_var unless local_var.nil?
      call_tp.instance_var = instance_var unless instance_var.nil?
    end

    def to_hash
      stringify
      ret_hash = GenerateResult.wanted_attributes(event).inject({}) do |memo, k|
        memo[k.to_s] = send(k)
        memo
      end

      if SourceRoute.proxy.config.event.include?(:return)
        ret_hash['return_value'] = return_value.nil? ? return_value.inspect : return_value
      end

      (INNER_ATTRS + CUSTOM_ATTRS).each do |k|
        ret_hash[k.to_s] = send(k) if send(k)
      end
      ret_hash['return_value_class'] = ret_hash['return_value'].class.name
      ret_hash['params_var_class'] = ret_hash['params_var'].class.name if ret_hash['params_var']
      ret_hash['local_var_class'] = ret_hash['local_var'].class.name if ret_hash['local_var']
      ret_hash['instance_var_class'] = ret_hash['instance_var'].class.name if ret_hash['instance_var']
      ret_hash
    end

    # todo: this is a mutable method
    # not a good solution.
    # we should use it on the return hash of method to_hash
    def stringify
      if GenerateResult.wanted_attributes(event).include?(:defined_class)
        self.defined_class = defined_class.to_s
      end
      if GenerateResult.wanted_attributes(event).include?(:return_value)
        if return_value.nil? or return_value.is_a? Symbol or
          # ActiveRecord::ConnectionAdapters::Column override method ==
          (return_value.is_a? String and return_value == '')
          self.return_value = return_value.inspect
        else
          self.return_value = return_value.to_s
        end
      end
      self.event = event.to_s
      self.method_id = method_id.to_s
      self
    end

    def collect_required_data
      get_attrs
      get_self_refer

      get_local_or_params_var if SourceRoute.proxy.config.include_local_var
      get_instance_var if SourceRoute.proxy.config.include_instance_var and return_event?
      self
    end

    def get_attrs
      GenerateResult.wanted_attributes(@tp_ins.event).each do |key|
        if @tp_ins.respond_to?(key)
          send("#{key}=", @tp_ins.send(key))
        end
      end
    end

    def get_self_refer
      self.tp_self_refer = SourceRoute.proxy.result_builder.tp_self_caches
                           .map(&:__id__).index(@tp_ins.self.__id__)
    end

    def get_local_or_params_var
      local_var_hash = {}
      # Warn: @tp_ins.binding.eval('local_variables') =! @tp_ins.binding.send('local_variables')
      @tp_ins.binding.eval('local_variables').each do |v|
        # I need comment out why i need source_route_display
        # must be some strange variables require it
        local_var_hash[v] = @tp_ins.binding.local_variable_get(v).source_route_display
      end
      if local_var_hash != {}
        if call_event?
          self.params_var = local_var_hash
        elsif return_event? # what about other event?
          self.local_var = local_var_hash
        end
      end
    end

    def get_instance_var
      instance_var_hash = {}
      @tp_ins.self.instance_variables.each do |key|
        instance_var_hash[key] = @tp_ins.self.instance_variable_get(key).source_route_display
      end
      self.instance_var = instance_var_hash if instance_var_hash != {}
    end
  end # END TpResult
end
