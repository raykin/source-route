module SourceRoute

  class Wrapper
    include Singleton

    TRACE_POINT_METHODS = [:defined_class, :method_id, :path, :lineno]

    attr_accessor :condition, :tp, :tp_attrs_results

    Condition = Struct.new(:events, :negatives, :positive, :result_config)

    class Condition

      TRACE_POINT_METHODS.each do |m|
        define_method m do |v|
          positive[m] = v.to_s
        end

        define_method "#{m}_not" do |v|
          negatives[m] = v.to_s
        end
      end

      def event(*v)
        # why need self? without self, the events will not really changed, why?. seems a bug in ruby
        self.events = v.map(&:to_sym) unless v == []
      end

      def output_format(data = nil, &block)
        result_config.format = block_given? ? block : data
      end

      # true means tp block current tp
      def filter_check(tp)
        return true if negatives_check(tp)
        return true if positive_check(tp)
      end

      def negatives_check(tp)
        negatives.any? do |method_key, value|
          tp.send(method_key).to_s =~ Regexp.new(value)
        end
      end

      def positive_check(tp)
        positive.any? do |method_key, value|
          tp.send(method_key).to_s !~ Regexp.new(value)
        end
      end

      def possible_check
      end
    end

    def initialize
      reset
    end

    def reset
      @tp.disable if @tp
      @condition = Condition.new([:call], {}, {},
                                 TpResult::Config.new('silence', [], false, false))
      @tp_attrs_results = []
      self
    end

    def trace
      # dont wanna init it in tp block, cause tp block could run thousands of times in one cycle trace
      tp_result = TpResult.new(self)

      track = TracePoint.new *condition.events do |tp|

        next if condition.filter_check(tp)

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
