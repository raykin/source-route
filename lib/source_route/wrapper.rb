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

        result_config.show_additional_attrs = [:path, :lineno]
        # JSON serialize trigger many problems when handle complicated object

        # a Back Door to open more data. but be care it could trigger weird crash when Jsonify these vars
        if value == 10
          result_config.include_instance_var = true
          result_config.include_local_var = true
        end
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
      build_result = GenerateResult.new(self)
      tp_filter = TpFilter.new(condition)

      track = TracePoint.new *condition.events do |tp|

        next if tp_filter.block_it?(tp)

        unless condition.result_config.format.is_a? Proc
          ret_data = build_result.build(tp)
          @tp_result_chain.push(ret_data)
        end

        build_result.output(tp)
      end
      track.enable
      self.tp = track
    end

    def jsonify_events
      Oj.dump(@condition.events.map(&:to_s))
    end

    def jsonify_tp_result_chain
      # puts tp_result_chain.stringify
      json_array = tp_result_chain.map { |result| Jsonify.dump(result) }
      '[ ' + json_array.join(',') + ' ]'
    end

    def jsonify_tp_self_caches
      Oj.dump(tp_self_caches.clone.map(&:to_s))
    end
  end # END Wrapper

end
