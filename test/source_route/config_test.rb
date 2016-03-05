require 'test_helper'

module SourceRoute
  class ConfigTest < Minitest::Test

    def test_trace_filter_methods
      assert TRACE_FILTER_METHODS.include?(:defined_class_not)
      assert TRACE_FILTER_METHODS.include?(:method_id_not)
      assert TRACE_FILTER_METHODS.include?(:path)
      assert TRACE_FILTER_METHODS.frozen?
    end

    def test_block_parser
      block_parser = BlockConfigParser.new
      config = block_parser.run do
        event :call, 'c_call'
        method_id_not :exception_method_name
        defined_class 'ActiveRecord::Callback'
        output_format 'silence'
      end
      assert_equal [:call, :c_call], config.event
      assert_equal 'exception_method_name', config.negatives[:method_id]
      assert_equal 'ActiveRecord::Callback', config.positives[:defined_class]
      assert_equal :silence, config.output_format
    end

    def test_block_parser_with_full_feature
      block_parser = BlockConfigParser.new
      config = block_parser.run do
        event :call, 'c_call'
        path 'your_rails_application_root_dir_name'
        filename 'trial.html'
        full_feature 10
      end
      assert_equal 3, config.event.size
      assert_includes config.event, :return
      assert config.import_return_to_call
      assert 'trial.html', config.filename
      assert_includes config.positives[:path], 'root_dir'
    end

    def test_block_parser_with_params
      block_parser = BlockConfigParser.new
      config = block_parser.run 'wanted' do
      end
      assert_equal 'wanted', config.positives[:defined_class]
      assert_equal 'wanted', config.positives[:method_id]
    end

    def test_block_parser_without_block
      block_parser = BlockConfigParser.new
      config = block_parser.run 'ActiveSupport'
      assert_equal 'ActiveSupport', config.positives[:defined_class]
    end

    def test_full_feature_of_params_parser
      params = {output_format: 'html', event: :c_call,
                defined_class: 'ActiveRecord::Base',
                method_id_not: ['initialize', 'nonsense']
               }
      config = ParamsConfigParser.run(params)
      assert_equal :html, config.output_format
      assert_equal [:c_call], config.event
      assert_equal 'ActiveRecord::Base', config.positives[:defined_class]
      assert_equal 'initialize|nonsense', config.negatives[:method_id]
    end

    def test_default_value_of_config
      params = {defined_class: [:Rack, :ActiveRecord]}
      config = ParamsConfigParser.run(params)
      assert_equal :test, config.output_format
      assert_equal [:call], config.event
      assert_equal 'Rack|ActiveRecord', config.positives[:defined_class]
    end

    def test_config_formulize
      config = Config.new
      config.output_format = 'html'
      config.event = ['return', :call]
      config.formulize
      assert_equal :html, config.output_format
      assert_equal [:return, :call], config.event
    end
  end

end
