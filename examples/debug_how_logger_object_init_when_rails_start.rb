#!/usr/bin/env ruby

# usage: cover bin/rails with this file and run bundle exec rails c to start your console then exit your console

require 'rails'

require 'source_route'

SourceRoute.enable do
  defined_class 'ActiveSupport::Configurable'
  method_id :logger
  full_feature 10
end

APP_PATH = File.expand_path('../../config/application',  __FILE__)

require_relative '../config/boot'

require 'rails/commands'

at_exit do
  SourceRoute.output_html
end
