module SourceRoute
  TP_FILTER = [:defined_class, :method_id, :path, :lineno].freeze
  TP_FILTER_METHODS = (TP_FILTER + TP_FILTER.map { |tpf| "#{tpf}_not".to_sym }).freeze

  class Config

    DIRECT_ATTRS = [:event, :full_feature, :debug,
                    :output_format, :show_additional_attrs,
                    :filename, :include_local_var, :include_instance_var,
                    :import_return_to_call
                   ]

    attr_accessor *DIRECT_ATTRS
    attr_accessor :negatives, :positives

    def initialize
      @event = [:call]
      @output_format = :test
      @positives = {}
      @negatives = {}
    end

    def formulize
      symbolize_output_format
      event_becomes_array
    end

    def symbolize_output_format
      self.output_format = output_format.to_sym if output_format.respond_to? :to_sym
    end

    def event_becomes_array
      self.event = Array(event).map(&:to_sym)
    end

    def has_call_and_return_event
      event.include? :return and event.include? :call
    end
  end # END Config

  class BlockConfigParser
    attr_accessor :ret_params

    def initialize
      @ret_params = {}
    end

    def run(cname = nil, &block)
      ret_params[:defined_class] = cname unless cname.nil?
      instance_eval(&block)
      ParamsConfigParser.run(@ret_params)
    end

    Config::DIRECT_ATTRS.each do |attr|
      define_method attr do |v=true|
        ret_params[attr] = v
      end
    end

    # override
    [:event, :show_additional_attrs].each do |attr|
      define_method attr do |*v|
        ret_params[attr] = v unless v == []
      end
    end

    # override
    def output_format(data = nil, &block)
      ret_params[:output_format] = block_given? ? block : data
    end

    TP_FILTER_METHODS.each do |m|
      define_method m do |*v|
        ret_params[m] = v
      end
    end

  end # END BlockConfigParser

  module ParamsConfigParser
    extend self

    TP_FILTER.each do |m|
      define_method m do |v|
        @config.positives[m] = Array(v).flatten.map(&:to_s).join('|')
      end

      define_method "#{m}_not" do |*v|
        @config.negatives[m] = Array(v).flatten.map(&:to_s).join('|')
      end
    end

    def run(params)
      @config = Config.new
      params.each do |k, v|
        @config.send("#{k}=", v) if Config::DIRECT_ATTRS.include? k.to_sym
        send(k, v) if (TP_FILTER_METHODS + [:full_feature]).include? k.to_sym
      end
      @config
    end

    # todo. value equal 10 may not be a good params
    def full_feature(value=true)
      return unless value
      @config.formulize
      @config.event = (@config.event + [:call, :return]).uniq
      @config.import_return_to_call = true
      @config.show_additional_attrs = [:path, :lineno]
      # JSON serialize trigger many problems when handle complicated object(in rails?)
      # a Back Door to open more data. but be care it could trigger weird crash when Jsonify these vars
      if value == 10
        @config.include_instance_var = true
        @config.include_local_var = true
      end
    end
  end # END ParamsConfigParser

end
