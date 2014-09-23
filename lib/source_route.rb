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

  def wrapper
    @@wrapper ||= Wrapper.instance
  end

  def reset
    wrapper.reset
  end

  def disable
    wrapper.reset
  end

  def enable(match = nil, &block)
    wrapper.reset

    wrapper.method_id(match) if match # TODO in future future: should add as wrapper.method_id_or(match)

    wrapper.instance_eval(&block) if block_given?

    wrapper.trace
  end

  # Not implemented. used in irb or pry.
  def trace(opt, &block)
    wrapper.reset
    opt.each do |k, v|
      wrapper.send(k, v)
    end
    wrapper.trace
    yield
    wrapper.tp.disable
    SourceRoute.build_html_output if opt[:output_format] == :html
  end

  def build_html_output
    SourceRoute::Formats::Html.render(wrapper)
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
