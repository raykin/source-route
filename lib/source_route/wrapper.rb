module SourceRoute

  class Wrapper
    include Singleton

    TRACE_POINT_METHODS = [:defined_class, :method_id, :path, :lineno]

    attr_accessor :condition, :tp, :result_builder

    Condition = Struct.new(:events, :negatives, :positive, :result_config) do
      def initialize(e=[:call], n={}, p={}, r=GenerateResult::Config.new)
        @debug = false
        super(e, n, p, r)
      end
    end

    class Condition

      TRACE_POINT_METHODS.each do |m|
        define_method m do |*v|
          positive[m] = v.flatten.map(&:to_s).join('|')
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

      def debug(value=false)
        @debug = value
      end

      def is_debug?
        @debug
      end
    end

    def initialize
      reset
    end

    def reset
      @tp.disable if defined? @tp
      @condition = Condition.new
      @result_builder = GenerateResult.new(self)
      GenerateResult.clear_wanted_attributes
      self
    end

    def trace
      # dont wanna init it in tp block, cause tp block could run thousands of times in one cycle trace

      tp_filter = TpFilter.new(condition)

      track = TracePoint.new *condition.events do |tp|

        next if tp_filter.block_it?(tp)

        # immediate output trace point result
        # here is confused. todo
        # should move tp_result_chain to result generator
        @result_builder.output(tp)
        # if condition.result_config.format == :console
        #   ret_data = build_result.build(tp)
        #   @tp_result_chain.push(ret_data)
        #   build_result.output(tp)
        # elsif condition.result_config.format.is_a? Proc
        #   build_result.output(tp)
        # else
        #   # why not push the tp to result chain
        #   ret_data = build_result.build(tp)
        #   @tp_result_chain.push(ret_data)
        # end
      end
      track.enable
      self.tp = track
    end

    def tp_result_chain
      result_builder.tp_result_chain
    end
  end # END Wrapper

end
