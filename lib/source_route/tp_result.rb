module SourceRoute
  # TracePoint Wrapper delegated to hash
  class TpResult
    attr_accessor :core

    extend Forwardable
    def_delegators :@core, :[], :merge, :merge!, :reject, :has_key?, :values, :[]=

    def initialize(data)
      @core = data
    end

    def found_opposite
      @opposite_exist = true
    end

    def locate_opposite?
      @opposite_exist
    end

    def return_event?
      @core[:event] == :return
    end

    def call_event?
      @core[:event] == :call
    end

    def ==(other)
      @core[:tp_self_refer] == other[:tp_self_refer] and @core[:method_id] == other[:method_id] and
        @core[:defined_class] == other[:defined_class]
    end

    def matched?
      @core[:matched]
    end

    def return_assign_call(tp)
      @core[:matched] = true
      tp[:return_value] = @core[:return_value]
      tp[:local_var] = @core[:local_var] if has_key? :local_var
      tp[:instance_var] = @core[:instance_var] if has_key? :instance_var
    end

    def stringify
      dup_core = @core.dup
      # to_s is safer than inspect
      # ex: inspect on ActiveRecord_Relation may crash
      dup_core[:defined_class] = dup_core[:defined_class].to_s if dup_core.has_key?(:defined_class)
      dup_core[:return_value] = dup_core[:return_value].source_route_display if dup_core.has_key?(:return_value)
      dup_core
    end
  end
end
