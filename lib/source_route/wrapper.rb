module SourceRoute

  class Wrapper
    include Singleton

    TRACE_POINT_METHODS = [:defined_class, :method_id, :path, :lineno]

    attr_accessor :condition, :tp, :tp_attrs_results

    Condition = Struct.new(:events, :negative, :positive, :result_config)

    class Condition

      TRACE_POINT_METHODS.each do |m|
        define_method m do |v|
          positive[m] = v.to_s
        end

        define_method "#{m}_not" do |v|
          negative[m] = v.to_s
        end
      end

      def event(*v)
        # why need self? without self, the events will not really changed, why?. seems a bug in ruby
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
      @condition = Condition.new([:call], {}, {},
                                 TpResult::Config.new('silence', [], false, false))
      @tp_attrs_results = []
      self
    end

    def trace
      # dont wanna init it in tp block, cause tp block could run thousands of times in one cycle trace
      tp_result = TpResult.new(self)

      track = TracePoint.new *condition.events do |tp|
        # todo: it's better to change the break check to condition methods to make more flexible
        negative_break = condition.negative.any? do |method_key, value|
          tp.send(method_key).to_s =~ Regexp.new(value)
        end
        next if negative_break

        positive_break = condition.positive.any? do |method_key, value|
          tp.send(method_key).to_s !~ Regexp.new(value)
        end
        next if positive_break

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
