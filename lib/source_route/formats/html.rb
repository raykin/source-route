require 'slim'
require 'json'

module SourceRoute
  module Formats

    module Html

      def self.render(results)
        template_path = File.expand_path "../html_template.slim", __FILE__
        html_output_str = Slim::Template.new(template_path).render(results)
        File.open("#{Time.now.strftime('%H%M%S-%m-%d')}-source-route.html", 'w') do |f|
          f << html_output_str
        end
      end

    end
  end
end
