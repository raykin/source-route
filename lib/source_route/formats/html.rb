require 'slim'
require 'json'

module SourceRoute
  module Formats
    module Html

      # results is instance of Wrapper
      def self.slim_render(results)
        template_path = File.expand_path "../html_template.slim", __FILE__
        slim_template = Slim::Template.new(template_path)

        filename = results.condition.result_config[:filename] ||
          "#{Time.now.strftime('%H%M')}-source-route.html"
        if results.condition.result_config[:import_return_to_call] and results.condition.has_call_and_return_event
          results.import_return_value_to_call_results
        end
        html_output_str = slim_template.render(results)
        File.open(filename, 'w') do |f|
          f << html_output_str
        end
      end

    end # END Html
  end
end
