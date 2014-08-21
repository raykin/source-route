require 'ostruct'
require 'logger'
require 'singleton'

require 'awesome_print'

require "source_route/version"
require "source_route/wrapper"
require "source_route/results"
require "source_route/nature_value"


module SourceRoute
  extend self

  def enable(match = nil, &block)
    wrapper = Wrapper.instance

    wrapper.method_id(match) if match
    wrapper.instance_eval(&block) if block_given?

    trace = TracePoint.new wrapper.conditions.event do |tp|
      negative_broken = wrapper.conditions.negative.any? do |method_key, value|
        tp.send(method_key).nature_value =~ Regexp.new(value)
      end
      next if negative_broken
      positive_broken = wrapper.conditions.positive.any? do |method_key, value|
        tp.send(method_key).nature_value !~ Regexp.new(value)
      end
      next if positive_broken
      wrapper.tp_caches.push(tp)
      results = Results.new(wrapper)
      results.output(tp)
    end
    trace.enable
    trace
  end

  # Not implement yet
  class Logger < Logger
  end
end
