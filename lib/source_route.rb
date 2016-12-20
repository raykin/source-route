require 'ostruct'
require 'singleton'
require 'forwardable'
require 'oj'
require 'awesome_print'

require "source_route/core_ext"
require "source_route/version"
require "source_route/config"
require "source_route/proxy"
require "source_route/generate_result"
require "source_route/tp_result"
require "source_route/trace_chain"
require "source_route/trace_filter"
require 'source_route/json_overrides/activerecord_associations_association'

begin
  if Rails
    require 'source_route/rails_plugins/source_track_middleware'
    ActiveSupport.on_load(:after_initialize, yield: true) do
      # make it respond to to_s. In rails source, almost all of its methods are removed, including to_s.
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

  def proxy
    @@proxy ||= Proxy.instance
  end

  def reset
    proxy.reset
  end

  def disable
    if proxy.tp.nil?
      puts 'Error: You try to call disable on nil object, do you define SourceRoute ?'
    else
      proxy.tp.disable
    end
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
