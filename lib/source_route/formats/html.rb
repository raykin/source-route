require 'slim'
require 'json'

module SourceRoute
  module Formats
    module Html

      def self.slim_render(wrapper)
        result_config = wrapper.condition.result_config
        template_path = File.expand_path "../html_template.slim", __FILE__
        slim_template = Slim::Template.new(template_path, pretty: true)

        filename = result_config[:filename] || "#{Time.now.strftime('%H')}-source-route.html"

        if result_config.import_return_to_call and wrapper.condition.has_call_and_return_event
          wrapper.import_return_value_to_call_chain
          wrapper.treeize_call_chain
        end
        # TODO: any exception triggered in render method will be absorb totally, how to fix it?
        html_output_str = slim_template.render(wrapper)
        File.open(filename, 'w') do |f|
          f << html_output_str
        end
      end

    end # END Html
  end
end
