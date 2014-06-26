require 'test_helper'
require 'ap'
class SourceRoute::WrapperTest < Minitest::Test

  def setup
  end

  def test_engine_instance_return_trace_point_instance
    sw = SourceRoute::Wrapper.new(/nonsense/).engine_instance
    assert sw.is_a? TracePoint
  end

  def test_conditions
    sw = SourceRoute::Wrapper.new(/nonsense/) do |source_route|
      source_route.exclude(defined_class: /none/).
        exclude(method_id: 'undefined')
    end

    conditions_of_no = sw.conditions[:no]
    assert_equal(/none/, conditions_of_no[:defined_class])
    assert_equal('undefined', conditions_of_no[:method_id])
  end

  def test_engine_instance_enable
    sw = SourceRoute::Wrapper.new('nonsense').engine_instance
    sw.enable
    assert sw.enabled?
  end


end
