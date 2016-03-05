require 'slim'
require 'json'

module SourceRoute
  module Formats
    module Html

      def self.slim_render(proxy)

        if proxy.config.use_tree_version2
          template_path = File.expand_path "../html_output2.slim", __FILE__
        else
          template_path = File.expand_path "../html_semantic.slim", __FILE__
        end
        slim_template = Slim::Template.new(template_path, pretty: true)

        filename = proxy.config.filename || "#{Time.now.strftime('%H')}-source-route.html"

        if proxy.config.import_return_to_call and proxy.config.has_call_and_return_event
          proxy.result_builder.import_return_value_to_call_chain
          if proxy.config.use_tree_version2
            proxy.result_builder.treeize_call_chain2
          else
            proxy.result_builder.treeize_call_chain
          end
        end
        # TODO: any exception triggered in render method will be absorb totally, how to fix it?
        html_output_str = slim_template.render(proxy.result_builder)
        File.open(filename, 'w') do |f|
          f << html_output_str
        end
      end

    end # END Html
  end
end
