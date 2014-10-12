module SourceRoute

  class TpFilter
    def initialize(condition)
      @condition = condition
    end

    # to improve performance, we didnt assign tp as instance variable
    def block_it?(tp)
      return true if negative_check(tp)
      return false if positive_check(tp)
      true
    end

    def negative_check(tp)
      @condition.negatives.any? do |method_key, value|
        tp.send(method_key).to_s =~ Regexp.new(value)
      end
    end

    def positive_check(tp)
      return true if @condition.positive == {}
      @condition.positive.any? do |method_key, value|
        tp.send(method_key).to_s =~ Regexp.new(value)
      end
    end

  end
end
