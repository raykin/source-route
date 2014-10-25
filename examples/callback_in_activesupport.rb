require 'active_support/callbacks'

require 'source_route'

SourceRoute.enable do
  event :call, :return
  defined_class 'ActiveSupport::Callbacks', 'PersonRecord'
  method_id :base_save, :saving_message, :callback
  result_config.import_return_to_call = true
end

class Record
  include ActiveSupport::Callbacks
  define_callbacks :save

  def base_save
    run_callbacks :save do
      puts "- save"
    end
  end
end

class PersonRecord < Record
  set_callback :save, :before, :saving_message

  def saving_message
    puts "saving..."
  end
end

person = PersonRecord.new
person.base_save

SourceRoute.build_html_output
