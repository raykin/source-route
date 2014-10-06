require 'minitest/autorun'
require File.join(File.dirname(__FILE__), 'sample_app')
require File.join(File.dirname(__FILE__), 'fake_app')

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'source_route'
require 'pry'
require 'pry-byebug'
