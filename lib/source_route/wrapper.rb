module SourceRoute

  class Wrapper # todo Rename it to Proxy
    include Singleton

    attr_accessor :condition, :tp, :result_builder

    # TODO: rename it to config and move it to a single file
    Condition = Struct.new(:events, :negatives, :positive, :result_config) do
      def initialize(e=[:call], n={}, p={}, r=GenerateResult::Config.new)
        @debug = false
        super(e, n, p, r)
      end
    end

    class Condition

      TRACE_POINT_METHODS = [:defined_class, :method_id, :path, :lineno]

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

      # todo. value equal 10 is not a good params
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
      # only init once, so its @collected_data seems not useful
      @result_builder = GenerateResult.new(self)
      GenerateResult.clear_wanted_attributes
      self
    end

    def trace
      tp_filter = TpFilter.new(condition)
      track = TracePoint.new(*condition.events) do |tp|
        next if tp_filter.block_it?(tp)
        @result_builder.output(tp)
      end
      track.enable
      self.tp = track
    end

    def tp_result_chain
      result_builder.tp_result_chain
    end
  end # END Wrapper

end
