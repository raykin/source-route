#!/usr/bin/env ruby

# copy this file content to bin/rails, then run ./bin/rails s, it should show init files in order

require 'source_route'

SourceRoute.enable do
  file_paths = []
  event :line
  path 'your_rails_application_root_dir_name'
  output_format do |tp|
    unless file_paths.include? tp.path
      puts tp.path
      file_paths.push(tp.path)
    end
  end
end

# The above source route block defines trace point feature as following
    # files = []
    # tp = TracePoint.new(:line) do |tp|
    #   if tp.path =~ /your_rails_application_root_dir_name/
    #     unless files.include? tp.path
    #       puts "#{tp.path}".inspect
    #       files.push(tp.path)
    #     end
    #   end
    # end
    # tp.enable

APP_PATH = File.expand_path('../../config/application',  __FILE__)
require_relative '../config/boot'
require 'rails/commands'
