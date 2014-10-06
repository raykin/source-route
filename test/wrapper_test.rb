require 'test_helper'

module SourceRoute
  class WrapperTest < Minitest::Test

    def setup
      @wrapper = Wrapper.instance
      super
    end

    def teardown
      SourceRoute.reset
      super
    end

    def test_enable_return_true
      @source_route = SourceRoute.enable /nnnonsense/
      assert @source_route
      assert_equal @wrapper, SourceRoute.wrapper
    end

    def test_catch_call_event
      SourceRoute.enable do
        event :call
        method_id /nonsense/
        output_format :test
      end
      SampleApp.new.nonsense

      assert @wrapper.tp
    end

    def test_catch_class_name_by_first_parameter
      skip
      # not supported yet
      @source_route = SourceRoute.enable 'sampleapp'
      SampleApp.new.nonsense

      assert @wrapper.tp_attrs_results.size > 0
    end

    def test_match_class_name
      @source_route = SourceRoute.enable do
        defined_class 'SampleApp'
      end

      SampleApp.new.nonsense
      assert @wrapper.tp_attrs_results.size > 0
    end

    def test_source_route_with_one_parameter
      @source_route = SourceRoute.enable 'nonsense'
      SampleApp.new.nonsense

      ret_value = @wrapper.tp_attrs_results.last
      assert_equal SampleApp, ret_value[:defined_class]
    end

    def test_wrapper_reset
      SourceRoute.enable 'nonsense'
      SampleApp.new.nonsense
      assert_equal 1, @wrapper.tp_attrs_results.size

      SourceRoute.reset
      SampleApp.new.nonsense

      assert_equal 0, @wrapper.tp_attrs_results.size
    end

    def test_source_route_with_block_only
      paths = []
      SourceRoute.enable 'nonsense' do
        SampleApp.new.nonsense
        output_format do |tp|
          paths.push tp.path
        end
      end
      SampleApp.new.nonsense

      assert_equal 0, @wrapper.tp_attrs_results.size
      assert_equal 1, paths.size
      assert_includes paths.first, 'sample_app'
    end

    def test_trace_without_first_hash_option
      SourceRoute.trace output_format: :test do
        SampleApp.new.nonsense
      end
      assert @wrapper.tp_attrs_results.size > 0
      refute @wrapper.tp.enabled?
    end

    def test_trace_two_events
      SourceRoute.enable 'nonsense' do
        events [:call, :return]
      end
      SampleApp.new.nonsense
      assert_equal 2, @wrapper.tp_attrs_results.size
    end

    def test_show_local_variables
      SourceRoute.enable 'nonsense_with_params' do
        output_include_local_variables
      end

      SampleApp.new.nonsense_with_params(88)
      assert_equal 1, @wrapper.tp_attrs_results.size

      ret_value = @wrapper.tp_attrs_results.last

      assert_equal 88, ret_value[:local_var][:param1]
      assert_equal nil, ret_value[:local_var][:param2]
    end

    def test_track_local_var_when_event_is_return
      SourceRoute.enable 'nonsense_with_params' do
        events :return
        output_include_local_variables
      end

      SampleApp.new.nonsense_with_params(88)
      assert_equal 1, @wrapper.tp_attrs_results.size

      ret_value_for_return_event = @wrapper.tp_attrs_results.last
      assert_equal 88, ret_value_for_return_event[:local_var][:param1]
      assert_equal 5, ret_value_for_return_event[:local_var][:param2]
    end

    def test_show_instance_vars
      @source_route = SourceRoute.enable 'nonsense' do
        output_include_instance_variables
      end

      SampleApp.new('ins sure').nonsense_with_instance_var

      assert_equal 2, @wrapper.tp_attrs_results.size
      ret_value = @wrapper.tp_attrs_results.pop

      assert_equal 'ins sure', ret_value[:instance_var][:@sample]
    end

    # Nothing has tested really when run rake cause ENV['ignore_html_generation'] was set to true
    def test_html_format_output_only
      @source_route = SourceRoute.enable do
        defined_class 'SampleApp'
        output_include_instance_variables
        output_include_local_variables
      end

      SampleApp.new.init_cool_app

      if ENV['ignore_html_generation'] == 'true'
        # do nothing. it was set in Rakefile, so rake test will not generate html file
      else
        SourceRoute.build_html_output
      end
    end

  end

end
