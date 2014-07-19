require 'test_helper'

module SourceRoute
  class WrapperTest < Minitest::Test

    def test_catch_call_event
      SourceRoute.enable do
        event :call
        method_id /nonsense/
      end
      SampleApp.new.nonsense
      w = Wrapper.instance
      assert w.results.size > 0
    end

  end

end
