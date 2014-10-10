require 'slim'
require 'json'

module SourceRoute
  module Formats
    module Html

      # results is instance of Wrapper
      def self.slim_render(results)
        template_path = File.expand_path "../html_template.slim", __FILE__
        slim_template = Slim::Template.new(template_path)

        html_output_str = slim_template.render(results)
        File.open("#{Time.now.strftime('%M%S-%H-%m-%d')}-source-route.html", 'w') do |f|
          f << html_output_str
        end
      end

    end # END Html
  end
end
