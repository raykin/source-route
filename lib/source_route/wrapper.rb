module SourceRoute

  class Wrapper

    attr_reader :conditions

    def initialize(keyword, event = [:call, :return])
      if keyword.is_a? String
        @keyword = Regexp.new(keyword)
      else
        @keyword = keyword
      end
      @event = event
      @conditions = Conditions.new.data
      yield self if block_given?
    end

    def engine_instance
      kw = @keyword
      conditions_of_no = @conditions[:no]
      TracePoint.new *@event do |tp|
        if conditions_of_no != {}
          conditions_of_no.each do |key, value|
            if key.to_sym == :defined_class
              if tp.defined_class and tp.defined_class.name =~ Regexp.new(value)
                return
              end
            end
          end
        end
        # TODO: move tp value into results array
        if (tp.defined_class and tp.defined_class.name =~ kw) or
            (tp.method_id and tp.method_id =~ kw)
          if tp.event == :call
            ap [tp.event, tp.lineno, tp.defined_class, tp.method_id, tp.binding.inspect]
          elsif tp.event == :return
            ap [tp.event, tp.lineno, tp.defined_class, tp.method_id, tp.return_value, tp.binding.inspect]
          end
        end
      end
    end

    def where(hash)
      @conditions[:yes].merge!(hash)
      self
    end

    def exclude(hash)
      @conditions[:no].merge!(hash)
      self
    end

    # Try subclass Hash, but feel not good
    class Conditions

      attr_reader :data
      def initialize
        @data = {yes: {}, no: {}}
      end

    end

  end

end
