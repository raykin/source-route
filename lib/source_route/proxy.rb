module SourceRoute

  class Proxy # todo Rename it to Proxy
    include Singleton

    attr_accessor :config, :tp, :result_builder

    def initialize
      reset
    end

    def reset
      @tp.disable if defined? @tp
      @config = Config.new
      # only init once, so its @collected_data seems not useful
      @result_builder = GenerateResult.new(self)
      GenerateResult.clear_wanted_attributes
      self
    end

    def trace
      trace_filter = TraceFilter.new(config)
      track = TracePoint.new(*config.event) do |tp|
        next if trace_filter.block_it?(tp)
        @result_builder.output(tp)
      end
      track.enable
      self.tp = track
    end

    def trace_chain
      result_builder.trace_chain
    end
  end # END Proxy

end
