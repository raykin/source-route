module SourceRoute

  class Wrapper
    include Singleton

    TRACE_POINT_METHODS = [:defined_class, :method_id, :path, :lineno]

    attr_accessor :condition, :tp
    attr_reader :tp_result_chain, :tp_self_caches

    extend Forwardable
    def_delegators :@tp_result_chain, :import_return_value_to_call_chain, :treeize_call_chain, :call_chain, :return_chain, :parent_length_list

    Condition = Struct.new(:events, :negatives, :positive, :result_config) do
      def initialize(e=[:call], n={}, p={}, r=GenerateResult::Config.new)
        super(e, n, p, r)
      end
    end

    class Condition

      TRACE_POINT_METHODS.each do |m|
        define_method m do |*v|
          positive[m] = v.map(&:to_s).join('|')
        end

        define_method "#{m}_not" do |*v|
          negatives[m] = v.map(&:to_s).join('|')
        end
      end

      def event(*v)
        self.events = v.map(&:to_sym) unless v == []
      end

      def output_format(data = nil, &block)
        result_config.format = block_given? ? block : data
      end

      def has_call_and_return_event
        events.include? :return and events.include? :call
      end

      def full_feature(value=true)
        return unless value

        self.events = [:call, :return]
        result_config.import_return_to_call = true
        result_config.include_tp_self = true

        result_config.show_additional_attrs = [:path, :lineno]
        # JSON serialize trigger many problems when handle complicated object
        # result_config.include_instance_var = true
        # result_config.include_local_var = true
      end
    end

    def initialize
      reset
    end

    def reset
      @tp.disable if defined? @tp
      @condition = Condition.new
      @tp_result_chain = TpResultChain.new
      @tp_self_caches = []
      self
    end

    def trace
      # dont wanna init it in tp block, cause tp block could run thousands of times in one cycle trace
      tp_result = GenerateResult.new(self)
      tp_filter = TpFilter.new(condition)

      track = TracePoint.new *condition.events do |tp|

        next if tp_filter.block_it?(tp)

        unless condition.result_config.format.is_a? Proc
          ret_data = tp_result.build(tp)
          @tp_result_chain.push(ret_data)
        end

        tp_result.output(tp)
      end
      track.enable
      self.tp = track
    end

    # TODO: move this into chain self
    def stringify_tp_self_caches
      tp_self_caches.clone.map(&:to_s)
    end

    def stringify_tp_result_chain
      deep_cloned = tp_result_chain.map do |tp_result|
        tp_result.clone
      end
      deep_cloned.map do |tr|
        # to_s is safer than inspect
        # ex: inspect on ActiveRecord_Relation may crash
        tr[:defined_class] = tr[:defined_class].to_s if tr.key?(:defined_class)
        if tr.key?(:return_value)
          if tr[:return_value].nil? or tr[:return_value] == ''
            tr[:return_value] = tr[:return_value].inspect
          else
            tr[:return_value] = tr[:return_value].to_s
          end
        end
        tr
      end
    end

    def jsonify_events
      JSON.dump(@condition.events.map(&:to_s))
    end

    def jsonify_tp_result_chain
      JSON.dump(stringify_tp_result_chain)
    end

    def jsonify_tp_self_caches
      JSON.dump(stringify_tp_self_caches)
    end
  end # END Wrapper

end
