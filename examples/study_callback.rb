require 'active_support/callbacks'

require 'source_route'

SourceRoute.enable do
  method_id 'base_decorate', 'prepare_decorate'
  defined_class 'ActiveSupport::Callbacks', 'House', 'Filters'
  filename = 'trace_callback.html'
  full_feature 10
end

class House
  include ActiveSupport::Callbacks
  define_callbacks :decorate

  def base_decorate
    run_callbacks :decorate do
      puts "Let's decorate house"
    end
  end
end

class KattyHouse < House
  set_callback :decorate, :after, :prepare_decorate

  def prepare_decorate
    puts "Preparing: buy materials ......"
  end
end

katty_house = KattyHouse.new

katty_house.base_decorate

SourceRoute.output_html
