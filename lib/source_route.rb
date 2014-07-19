require "source_route/version"
require 'singleton'
require 'awesome_print'
require "source_route/wrapper"
require "source_route/nature_value"

module SourceRoute
  extend self

  def enable(&block)
    wrapper = Wrapper.instance
    wrapper.instance_eval(&block)
    TracePoint.new wrapper.conditions[:event] do |tp|
      negative_broken = wrapper.conditions[:negative].any? do |method_key, value|
        tp.send(method_key).nature_value =~ Regexp.new(value)
      end
      next if negative_broken
      positive_broken = wrapper.conditions[:positive].any? do |method_key, value|
        tp.send(method_key).nature_value !~ Regexp.new(value)
      end
      next if positive_broken
      wrapper.results.push(tp)
      wrapper.output_results(tp)
    end.enable
  end

end
