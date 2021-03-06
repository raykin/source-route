require 'slim'
require 'json'

module SourceRoute
  module Formats
    module Html

      def self.slim_render(proxy)

        template_path = File.expand_path "../html_semantic.slim", __FILE__
        slim_template = Slim::Template.new(template_path, pretty: true)

        filename = proxy.config.filename || "#{Time.now.strftime('%H')}-source-route.html"

        if proxy.config.import_return_to_call and proxy.config.has_call_and_return_event
          proxy.result_builder.import_return_value_to_call_chain
          proxy.result_builder.treeize_call_chain
        end
        # TODO: any exception triggered in render method will be absorb totally, how to fix it?
        html_output_str = slim_template.render(proxy.result_builder)
        File.write(filename, html_output_str)
      end

    end # END Html
  end
end
