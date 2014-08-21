require 'test_helper'

module SourceRoute
  class WrapperTest < Minitest::Test

    def teardown
      @source_route.disable if defined? @source_route
    end

    def test_enable_return_true
      @source_route = SourceRoute.enable /nnnonsense/
      assert @source_route
    end

    def test_catch_call_event
      @source_route = SourceRoute.enable do
        event :call
        method_id /nonsense/
      end
      SampleApp.new.nonsense
      w = Wrapper.instance
      assert w.tp_caches.size > 0
    end

    def test_source_route_with_only_one_parameter
      @source_route = SourceRoute.enable 'nonsense'
      SampleApp.new.nonsense
      w = Wrapper.instance
      assert w.tp_caches.size > 0
    end

    def test_show_local_variables
      @source_route = SourceRoute.enable 'nonsense'
      SampleApp.new.nonsense(88)
    end
  end

end
