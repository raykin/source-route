require 'ostruct'
require 'singleton'
require 'forwardable'
require 'oj' # Not sure how to correct use it with Rails
require 'awesome_print'

require "source_route/core_ext"
require "source_route/version"
require "source_route/config"
require "source_route/proxy"
require "source_route/generate_result"
require "source_route/tp_result"
require "source_route/trace_chain"
require "source_route/trace_filter"
require "source_route/call_trace_tree"
require 'source_route/json_overrides/activerecord_associations_association'
require 'source_route/override_rails'

module SourceRoute
  extend self

  def proxy
    @@proxy ||= Proxy.instance
  end

  def reset
    proxy.reset
  end

  def disable
    proxy.tp.disable
  end

  def enable(match = nil, &block)
    proxy.reset

    proxy.config = BlockConfigParser.new.run(match, &block)

    proxy.trace
  end

  def trace(opt, &block)
    proxy.reset
    proxy.config = ParamsConfigParser.run(opt)
    proxy.trace
    yield
    proxy.tp.disable
    SourceRoute.output_html if proxy.config.output_format == :html
  end

  def output_html
    SourceRoute.disable
    SourceRoute::Formats::Html.slim_render(proxy)
  end

  module Formats
    autoload :Html, 'source_route/formats/html'
  end
end
