module SourceRoute

  class Wrapper
    include Singleton

    attr_accessor :conditions, :results

    def initialize
      @conditions = {negative: {}, positive: {}, event: :call, output_format: [:defined_class, :event, :method_id]}
      @results = []
    end

    def event(v)
      @conditions[:event] = v.to_sym unless v.nil?
    end

    TRACE_POINT_METHODS = [:defined_class, :method_id, :path, :lineno]

    TRACE_POINT_METHODS.each do |m|
      define_method m do |v|
        @conditions[:positive][m] = v
      end

      define_method "#{m}_not" do |v|
        @conditions[:negative][m] = v
      end
    end

    def output_format(data = nil, &block)
      if data.nil?
        @conditions[:output_format] = block
      else
        @conditions[:output_format] = [data].flatten
      end
    end

    def output_results(trace_point_instance)
      tp = trace_point_instance
      if @conditions[:output_format].is_a? Array
        v = @conditions[:output_format].map do |key|
          tp.respond_to?(key) ? tp.send(key) : nil
        end
        ap v
      elsif @conditions[:output_format].is_a? Proc
        @conditions[:output_format].call(tp)
      end
    end

    def tp_event_map_to_methods
      @tp_event_map_to_methods ||= {
        return_value: [:return, :c_return, :b_return]
      }
    end

  end

end
