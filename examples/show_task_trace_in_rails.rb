# Usage: copying following in your Rakefile under rails root

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

SourceRoute.enable do
  defined_class 'WantedClass'
  # output_format :console # optional
end

Rails.application.load_tasks

at_exit do
  SourceRoute.build_html_output
end
