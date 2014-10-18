module SourceRoute

  class Wrapper
    include Singleton

    TRACE_POINT_METHODS = [:defined_class, :method_id, :path, :lineno]

    attr_accessor :condition, :tp, :tp_attrs_results

    Condition = Struct.new(:events, :negatives, :positive, :result_config) do
      def initialize(e=[:call], n={}, p={}, r=TpResult::Config.new)
        super(e, n, p, r)
      end
    end

    class Condition

      TRACE_POINT_METHODS.each do |m|
        define_method m do |*v|
          positive[m] = v.map(&:to_s).join('|')
        end

        define_method "#{m}_not" do |v|
          negatives[m] = v.map(&:to_s).join('|')
        end
      end

      def event(*v)
        # why need self? without self, the events will not really changed, why?. seems a bug in Struct
        self.events = v.map(&:to_sym) unless v == []
      end

      def output_format(data = nil, &block)
        result_config.format = block_given? ? block : data
      end

    end

    def initialize
      reset
    end

    def reset
      @tp.disable if @tp
      @condition = Condition.new
      @tp_attrs_results = []
      self
    end

    def trace
      # dont wanna init it in tp block, cause tp block could run thousands of times in one cycle trace
      tp_result = TpResult.new(self)
      tp_filter = TpFilter.new(condition)

      track = TracePoint.new *condition.events do |tp|

        next if tp_filter.block_it?(tp)

        unless condition.result_config.format.is_a? Proc
          ret_data = tp_result.build(tp)
          tp_attrs_results.push(ret_data)
        end

        tp_result.output(tp)
      end
      track.enable
      self.tp = track
      track
    end

  end # Wrapper

end
