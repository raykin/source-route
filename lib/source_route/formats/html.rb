require 'slim'
require 'json'

module SourceRoute
  module Formats
    module Html

      # results is instance of Wrapper
      def self.render(results)
        template_path = File.expand_path "../html_template.slim", __FILE__
        html_output_str = Slim::Template.new(template_path).render(results)
        File.open("#{Time.now.strftime('%M%S-%H-%m-%d')}-source-route.html", 'w') do |f|
          f << html_output_str
        end
      end

    end # END Html
  end
end
