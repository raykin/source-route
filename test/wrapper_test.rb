require 'test_helper'

module SourceRoute
  class WrapperTest < Minitest::Test

    def test_enable_return_true
      ret = SourceRoute.enable {}
      assert ret
    end

    def test_catch_call_event
      SourceRoute.enable do
        event :call
        method_id /nonsense/
      end
      SampleApp.new.nonsense
      w = Wrapper.instance
      assert w.results.size > 0
    end

    def test_source_route_with_only_one_parameter
      SourceRoute.enable 'nonsense'
      SampleApp.new.nonsense
      w = Wrapper.instance
      assert w.results.size > 0
    end

  end

end
