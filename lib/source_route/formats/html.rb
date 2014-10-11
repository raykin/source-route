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
        html_output_str = slim_template.render(results)
        File.open(filename, 'w') do |f|
          f << html_output_str
        end
      end

    end # END Html
  end
end
