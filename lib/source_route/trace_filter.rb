module SourceRoute

  class TraceFilter
    attr_accessor :cond
    def initialize(condition)
      @cond = condition
    end

    # to improve performance, we didnt assign tp as instance variable
    def block_it?(tp)
      if @cond.track_params
        return true if negative_check(tp)
        if positives_check(tp)
          return !tp.binding.eval('local_variables').any? do |v|
            tp.binding.local_variable_get(v).object_id == @cond.track_params
          end
        end
      else
        return true if negative_check(tp)
        return false if positives_check(tp)
      end
      true # default is blocked the tp
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
