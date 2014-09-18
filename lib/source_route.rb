require 'ostruct'
require 'logger'
require 'singleton'

require 'awesome_print'

require "source_route/version"
require "source_route/wrapper"
require "source_route/tp_result"
require "source_route/nature_value"

module SourceRoute
  extend self

  def enable(match = nil, &block)
    wrapper = Wrapper.instance
    wrapper.reset
    wrapper.method_id(match) if match
    wrapper.instance_eval(&block) if block_given?

    # dont wanna init it in tp block, cause tp block could run thousands of time in one cycle trace
    tp_result = TpResult.new(wrapper)

    trace = TracePoint.new wrapper.conditions.event do |tp|
      negative_break = wrapper.conditions.negative.any? do |method_key, value|
        tp.send(method_key).nature_value =~ Regexp.new(value)
      end
      next if negative_break
      positive_break = wrapper.conditions.positive.any? do |method_key, value|
        tp.send(method_key).nature_value !~ Regexp.new(value)
      end
      next if positive_break
      wrapper.tp_caches.push(tp)

      ret_data = tp_result.build(tp)
      tp_result.output
      wrapper.tp_attrs_results.push(ret_data)
    end
    trace.enable
    trace
  end

  # Not implement yet
  class Logger < Logger
  end
end

module SourceRoute
  module Formats
    autoload :Html, 'source_route/formats/html'
  end
end
