require 'test_helper'

module SourceRoute
  class WrapperTest < Minitest::Test

    def setup
      @wrapper = Wrapper.instance
      super
    end

    def teardown
      @source_route.disable if defined? @source_route
      super
    end

    def test_enable_return_true
      @source_route = SourceRoute.enable /nnnonsense/
      assert @source_route
    end

    def test_catch_call_event
      @source_route = SourceRoute.enable do
        event :call
        method_id /nonsense/
        output_format :test
      end
      SampleApp.new.nonsense

      assert @wrapper.tp_caches.size > 0
    end

    def test_source_route_with_only_one_parameter
      @source_route = SourceRoute.enable 'nonsense'
      SampleApp.new.nonsense
      assert @wrapper.tp_caches.size > 0
      ret_value = @wrapper.tp_attrs_results.last
      assert_equal SampleApp, ret_value[:defined_class]
    end

    def test_show_local_variables
      @source_route = SourceRoute.enable 'nonsense_with_params' do
        output_format :test
        output_include_local_variables
      end

      SampleApp.new.nonsense_with_params(88)
      assert_equal 1, @wrapper.tp_caches.size

      ret_value = @wrapper.tp_attrs_results.last

      assert_equal 88, ret_value[:local_var][:param1]
    end

    def test_show_instance_vars
      @source_route = SourceRoute.enable 'nonsense' do
        output_format :test
        output_include_instance_variables
      end

      SampleApp.new(:cool).nonsense_with_instance_var
      assert_equal 2, @wrapper.tp_caches.size
      ret_value = @wrapper.tp_attrs_results.pop

      assert_equal :cool, ret_value[:instance_var][:@cool]
    end

    # Nothing has tested really
    def test_html_format_output
      @source_route = SourceRoute.enable 'nonsense'

      SampleApp.new.nonsense

      SourceRoute::Formats::Html.render(@wrapper)
    end
  end

end
