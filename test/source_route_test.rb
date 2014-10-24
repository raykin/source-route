require 'test_helper'

class SourceRouteTest < Minitest::Test

  def setup
    @wrapper = SourceRoute::Wrapper.instance
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

  def test_show_addtional_attrs
    SourceRoute.enable 'nonsense' do
      result_config.show_additional_attrs = :path
    end
    SampleApp.new.nonsense

    assert_includes @wrapper.tp_attrs_results.first[:path], 'test'
  end

  def test_match_class_name_by_first_parameter
    @source_route = SourceRoute.enable 'SampleApp'
    SampleApp.new.nonsense

    assert @wrapper.tp_attrs_results.size > 0
  end

  def test_match_class_name
    @source_route = SourceRoute.enable do
      defined_class :SampleApp
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

  def test_trace_with_c_call
    SourceRoute.trace event: :c_call do
      'abc'.upcase
    end

    assert_equal 2, @wrapper.tp_attrs_results.size
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
      event :call, :return
    end
    SampleApp.new.nonsense
    assert_equal 2, @wrapper.tp_attrs_results.size
  end

  def test_show_local_variables
    SourceRoute.enable 'nonsense_with_params' do
      result_config.include_local_var = true
      output_format :console
    end

    SampleApp.new.nonsense_with_params(88)
    assert_equal 1, @wrapper.tp_attrs_results.size

    ret_value = @wrapper.tp_attrs_results.last

    assert_equal 88, ret_value[:local_var][:param1]
    assert_equal nil, ret_value[:local_var][:param2]
  end

  def test_track_local_var_when_event_is_return
    SourceRoute.enable 'nonsense_with_params' do
      event :return
      result_config.include_local_var = true
    end

    SampleApp.new.nonsense_with_params(88)
    assert_equal 1, @wrapper.tp_attrs_results.size

    ret_value_for_return_event = @wrapper.tp_attrs_results.last
    assert_equal 88, ret_value_for_return_event[:local_var][:param1]
    assert_equal 5, ret_value_for_return_event[:local_var][:param2]
  end

  def test_show_instance_vars
    @source_route = SourceRoute.enable 'nonsense' do
      result_config.include_instance_var = true
    end

    SampleApp.new('ins sure').nonsense_with_instance_var

    assert_equal 2, @wrapper.tp_attrs_results.size
    ret_value = @wrapper.tp_attrs_results.pop

    assert_equal 'ins sure', ret_value[:instance_var][:@sample]
  end

  def test_import_return_to_call
    SourceRoute.enable 'SampleApp' do
      event :call, :return
      result_config.include_instance_var = true
      result_config.include_local_var = true
      result_config.import_return_to_call = true
    end
    SampleApp.new.init_cool_app
    @wrapper.import_return_value_to_call_results
    assert @wrapper.call_tp_results[0].key?(:return_value), 'call results should contain return_value'
  end

  def test_order_call_sequence
    SourceRoute.enable 'SampleApp' do
      event :call, :return
    end
    SampleApp.new.nonsense_with_instance_var
    @wrapper.order_call_results
    @wrapper.order_call_results

    nonsense_call_tp = @wrapper.call_tp_results.find { |tp| tp[:method_id] == :nonsense }
    nonsense_with_instance_var_call_tp = @wrapper.call_tp_results.find { |tp| tp[:method_id] == :nonsense_with_instance_var }

    assert_equal [-1, nonsense_with_instance_var_call_tp[:order_id]], nonsense_call_tp[:parent_id]
    assert_equal 2, nonsense_call_tp[:parent_length]
  end

  # Nothing has tested really when run rake cause ENV['ignore_html_generation'] was set to true
  def test_html_format_output_with_two_events_and_filename
    @source_route = SourceRoute.enable do
      defined_class 'SampleApp'
      event :call, :return
      result_config.include_instance_var = true
      result_config.include_local_var = true
      result_config.filename = 'call_and_return_in_sample_app.html'
      result_config.import_return_to_call = true
    end

    SampleApp.new.init_cool_app

    if ENV['ignore_html_generation'] == 'true'
      # do nothing. cause it was set to false in Rakefile.
      # So Run rake test will not generate html file, run ruby -Itest test/source_route.rb will generate output file
    else
      SourceRoute.build_html_output
    end
  end

end
