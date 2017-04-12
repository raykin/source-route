module SourceRoute

  class TraceFilter
    attr_accessor :cond
    def initialize(condition)
      @cond = condition
    end

    # to improve performance, we didnt assign tp as instance variable
    def block_it?(tp)
      return true if negative_check(tp)
      return false if positives_check(tp)
      true
    end

    def negative_check(tp)
      cond.negatives.any? do |method_key, value|
        tp.send(method_key).to_s =~ Regexp.new(value)
      end
    end

    def positives_check(tp)
      return true if cond.positives == {}
      cond.positives.any? do |method_key, value|
        if method_key.to_sym == :defined_class
          tp.send(method_key).name =~ Regexp.new(value)
        else
          tp.send(method_key).to_s =~ Regexp.new(value)
        end
      end
    end

  end
end