require 'test_helper'

class SourceRouteTest < Minitest::Test

  def setup
    @proxy = SourceRoute::Proxy.instance
    super
  end

  def teardown
    SourceRoute.reset
    super
  end

  def test_enable_return_true
    @source_route = SourceRoute.enable 'nnnonsense'
    assert @source_route
    assert_equal @proxy, SourceRoute.proxy
  end

  def test_catch_call_event
    SourceRoute.enable do
      event :call
      method_id /nonsense/
      output_format :test
    end
    SampleApp.new.nonsense

    assert @proxy.tp
  end

  def test_show_addtional_attrs
    SourceRoute.enable 'nonsense' do
      show_additional_attrs :path
      full_feature
    end
    SampleApp.new.nonsense

    assert_includes @proxy.trace_chain.first.path, 'test'
  end

  def test_match_class_name_by_first_parameter
    @source_route = SourceRoute.enable 'SampleApp'
    SampleApp.new.nonsense

    assert @proxy.trace_chain.size > 0
  end

  def test_not_match
    SourceRoute.enable do
      defined_class 'SampleApp' # without it, a dead loop will occur
      method_id_not 'nonsense'
    end
    SampleApp.new.nonsense
    refute_includes @proxy.trace_chain.map(&:method_id).flatten, 'nonsense'
  end

  def test_match_multiple_class_name
    SourceRoute.enable do
      defined_class [:SampleApp, :String]
    end

    SampleApp.new.nonsense
    assert @proxy.trace_chain.size > 0
    assert_equal SampleApp, @proxy.trace_chain.last.defined_class
  end

  def test_source_route_with_one_parameter
    SourceRoute.enable 'nonsense' do
      output_format :test
    end
    SampleApp.new.nonsense

    ret_tp = @proxy.trace_chain.last
    assert_equal SampleApp, ret_tp.defined_class
  end

  def test_proxy_reset
    SourceRoute.enable 'nonsense'
    SampleApp.new.nonsense
    assert_equal 1, @proxy.trace_chain.size

    SourceRoute.reset
    SampleApp.new.nonsense

    assert_equal 0, @proxy.trace_chain.size
  end

  def test_source_route_with_block
    paths = []
    SourceRoute.enable 'nonsense' do
      SampleApp.new.nonsense
      output_format do |tp|
        paths.push tp.path
      end
    end
    SampleApp.new.nonsense

    assert_equal 0, @proxy.trace_chain.size
    assert_equal 1, paths.size
    assert_includes paths.first, 'sample_app'
  end

  def test_trace_with_c_call
    SourceRoute.trace(event: :c_call) { 'abc'.upcase }

    assert_equal 2, @proxy.trace_chain.size
  end

  def test_trace_with_full_feature
    SourceRoute.trace method_id: 'nonsense', full_feature: 10 do
      SampleApp.new.nonsense
    end
    first_result = @proxy.trace_chain.first
    assert_equal first_result.tp_self_refer, 0
  end

  # def test_trace_include_tp_self
  #   SourceRoute.trace method_id: 'nonsense', full_feature: true do
  #     SampleApp.new.nonsense
  #   end
  #   assert_equal 1, @proxy.tp_self_caches.size
  #   assert @proxy.tp_self_caches.first.is_a? SampleApp
  # end

  def test_stringify_trace_chain_only
    SourceRoute.trace method_id: 'nonsense', full_feature: true do
      SampleApp.new.nonsense
    end
    origin_trace_chain = @proxy.trace_chain
    assert @proxy.trace_chain.first.stringify.defined_class.is_a? String
    assert_equal origin_trace_chain, @proxy.trace_chain
  end

  def test_trace_without_first_hash_option
    SourceRoute.trace output_format: :test do
      SampleApp.new.nonsense
    end
    assert @proxy.trace_chain.size > 0
    refute @proxy.tp.enabled?
  end

  def test_trace_two_events
    SourceRoute.enable 'nonsense' do
      event :call, :return
    end
    SampleApp.new.nonsense
    assert_equal 2, @proxy.trace_chain.size
  end

  # but local var didnt displayed
  def test_show_local_variables
    SourceRoute.enable 'nonsense_with_params' do
      include_local_var true
      output_format :console
    end

    SampleApp.new.nonsense_with_params(88)

    ret_value = @proxy.trace_chain.last
  end

  def test_track_local_var_when_event_is_return
    SourceRoute.enable 'nonsense_with_params' do
      event :return
      include_local_var true
    end

    SampleApp.new.nonsense_with_params(88)
    assert_equal 1, @proxy.trace_chain.size

    ret_value_for_return_event = @proxy.trace_chain.last
    assert_equal 88, ret_value_for_return_event.local_var[:param1]
    assert_equal 5, ret_value_for_return_event.local_var[:param2]
  end

  def test_show_instance_vars_only
    SourceRoute.enable 'nonsense' do
      include_instance_var true
      event :call, :return
    end
    SampleApp.new('ins sure').nonsense_with_instance_var

    assert_equal 4, @proxy.trace_chain.size
    ret_value = @proxy.trace_chain.pop

    assert_equal 'ins sure', ret_value.instance_var[:@sample]
  end

  def test_import_return_to_call_only
    SourceRoute.enable 'SampleApp' do
      full_feature 10
    end
    SampleApp.new('cool stuff').init_cool_app
    @proxy.trace_chain.import_return_value_to_call_chain
    assert @proxy.trace_chain.call_chain[0].return_value, 'call results should contain return_value'
  end

  def test_order_call_sequence
    SourceRoute.enable 'SampleApp' do
      event :call, :return
    end
    SampleApp.new.nonsense_with_instance_var

    @proxy.trace_chain.treeize_call_chain
    call_results = @proxy.result_builder.trace_chain.call_chain

    nonsense_call_tp = call_results.find { |tp| tp.method_id == :nonsense }
    nonsense_with_instance_var_call_tp = call_results.find do |tp|
      tp.method_id == :nonsense_with_instance_var
    end
    assert_equal [nonsense_with_instance_var_call_tp.order_id], nonsense_call_tp.parent_ids
    assert_equal 1, nonsense_call_tp.parent_length
    assert_equal [0, 1], @proxy.result_builder.trace_chain.parent_length_list
    assert_equal [nonsense_call_tp.order_id], nonsense_with_instance_var_call_tp.direct_child_order_ids
  end

  # Nothing has tested really when run rake cause ENV['ignore_html_generation'] was set to true
  def test_html_format_output_with_two_events_and_filename
    @source_route = SourceRoute.enable do
      defined_class 'SampleApp'
      event :call, :return
      full_feature 10
      filename 'call_and_return_in_sample_app.html'
    end

    SampleApp.new.init_cool_app

    if ENV['ignore_html_generation'] == 'true'
      # do nothing. cause it was set to false in Rakefile.
      # So Run rake test will not generate html file, run ruby -Itest test/source_route.rb will generate output file
    else
      SourceRoute.output_html
    end
  end

end
