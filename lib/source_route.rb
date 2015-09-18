require 'ostruct'
require 'logger'
require 'singleton'
require 'forwardable'
require 'oj'
require 'awesome_print'

require "source_route/core_ext"
require "source_route/version"
require "source_route/wrapper"
require "source_route/jsonify"
require "source_route/generate_result"
require "source_route/tp_result"
require "source_route/tp_result_chain"
require "source_route/tp_filter"
require 'source_route/json_overrides/activerecord_associations_association'

begin
  if Rails
    ActiveSupport.on_load(:after_initialize, yield: true) do
      # make it respond to to_s. IN rails source, almost all of its methods are removed, including to_s.
      module ActiveSupport
        class OptionMerger
          def to_s
            "<#ActiveSupport #{__id__}>"
          end
        end
      end # END ActiveSupport
    end
  end
rescue NameError
  nil
end

module SourceRoute
  extend self

  def wrapper
    @@wrapper ||= Wrapper.instance
  end

  def reset
    wrapper.reset
  end

  def disable
    wrapper.tp.disable
  end

  def enable(match = nil, &block)
    wrapper.reset

    if match
      wrapper.condition.method_id(match)
      wrapper.condition.defined_class(match)
    end

    wrapper.condition.instance_eval(&block) if block_given?

    wrapper.trace
  end

  def trace(opt, &block)
    opt[:output_format] ||= :test
    wrapper.reset
    opt.each do |k, v|
      wrapper.condition.send(k, v)
    end

    wrapper.trace
    yield
    wrapper.tp.disable
    SourceRoute.build_html_output if opt[:output_format].to_sym == :html
  end

  def build_html_output
    SourceRoute.disable
    SourceRoute::Formats::Html.slim_render(wrapper)
  end

  def output_html
    build_html_output
  end

  # Not implement yet
  class Logger < Logger
  end

  module Formats
    autoload :Html, 'source_route/formats/html'
  end
end
