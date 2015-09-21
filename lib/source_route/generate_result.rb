module SourceRoute
  # How it work
  # 0. Config collect route options
  # 1. Proxy generate TracePoint Filter
  # 2. Proxy generate TracePoint Monitor Block
  # 3. Generator collect Wanted TracePoint
  # 4. Parse and Generate Useful data from wanted TracePoint
  # 5. Output data with correct format
  class GenerateResult

    attr_reader :tp_result_chain, :tp_self_caches, :collected_data

    extend Forwardable
    def_delegators :@tp_result_chain, :import_return_value_to_call_chain, :treeize_call_chain

    # see event description in TracePoint API Doc
    DEFAULT_ATTRS = {
      call: [:defined_class, :method_id],
      return: [:defined_class, :method_id, :return_value],
      c_call: [:defined_class, :method_id],
      line: [:path, :lineno],
      # following are not tested yet
      class: [:defined_class],
      end: [:defined_class],
      c_return: [:defined_class, :method_id, :return_value],
      raise: [:raised_exception],
      b_call: [:binding, :defined_class, :method_id],
      b_return: [:binding, :defined_class, :method_id, :return_value],
      thread_begin: [:defined_class, :method_id],
      thread_end: [:defined_class, :method_id]
    }

    def initialize(proxy)
      @proxy = proxy
      @tp_result_chain = TpResultChain.new
      @tp_self_caches = []
    end

    # it cached and only calculate once for one trace point block round
    def self.wanted_attributes(eve)
      event = eve.to_sym
      @wanted_attributes.fetch event do
        attrs = DEFAULT_ATTRS[event] + Array(SourceRoute.proxy.config.show_additional_attrs)
        attrs.push(:event)
        @wanted_attributes[event] = attrs.uniq
        @wanted_attributes[event]
      end
    end

    def self.clear_wanted_attributes
      @wanted_attributes = {}
    end

    def output(tp_ins)
      format = @config.output_format

      assign_tp_self_caches(tp_ins)
      # we cant call method on tp_ins outside of track block,
      # so we have to run it immediately
      @collected_data = TpResult.new(tp_ins)

      case format
      when :console
        console_put(tp_ins)
      when :html
        # we cant generate html right now becase the tp callback is still in process
        # so we gather data into array
        @tp_result_chain.push(TpResult.new(tp_ins))
      when :silence, :none
      # do nothing at now
      when :test
        @tp_result_chain.push(TpResult.new(tp_ins))
      when :stack_overflow
        console_stack_overflow
      when Proc
        format.call(tp_ins)
      else
        klass = "SourceRoute::Formats::#{format.to_s.capitalize}"
        ::SourceRoute.const_get(klass).render(self, tp_ins, @collected_data)
      end
    end

    # include? will evaluate @tp.self, if @tp.self is AR::Relation, it could cause problems
    # So that's why I use object_id as replace
    def assign_tp_self_caches(tp_ins)
      unless tp_self_caches.find { |tp_cache| tp_cache.object_id.equal? tp_ins.self.object_id }
        tp_self_caches.push tp_ins.self
      end
    end

    def jsonify_events
      Oj.dump(@proxy.config.event.map(&:to_s))
    end

    def jsonify_tp_result_chain
      Oj.dump(tp_result_chain.chain.map(&:to_hash))
      # tp_result_chain.to_json
      # json_array = tp_result_chain.map { |result| Jsonify.dump(result) }
      # '[ ' + json_array.join(',') + ' ]'
    end

    def jsonify_tp_self_caches
      Oj.dump(tp_self_caches.clone
               .map(&:to_s))
    end

    private

    def console_put(tp)
      ret = []
      ret << "#{collected_data.defined_class.inspect}##{collected_data.method_id}"
      left_attrs = self.class.wanted_attributes(tp.event) - [:defined_class, :method_id]
      left_values = left_attrs.inject({}) do |memo, key|
        memo[key] = collected_data.send(key)
        memo
      end
      unless left_values == {}
        ret << left_values
      end
      ap ret
    end

    def console_stack_overflow
      ap "#{collected_data.defined_class.inspect}##{collected_data.method_id}"
    end

  end # END GenerateResult

end
