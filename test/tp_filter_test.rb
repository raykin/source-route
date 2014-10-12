require 'test_helper'

module SourceRoute
  class Devise; end
  class Warden; end
  class User; end

  FakeTp = Struct.new(:method_id, :defined_class, :lineno)

  class TpFilterTest < Minitest::Test

    def setup
      @devise_tp = FakeTp.new(:auth, Devise, 5)
      @warden_tp = FakeTp.new(:auth, Warden, 6)
      @user_tp = FakeTp.new(:new, User, 8)
      @tps = [@devise_tp, @warden_tp, @user_tp]
      @result_config = TpResult::Config.new('silence', [], false, false)
    end

    def test_filter_method_not_auth
      cond = Wrapper::Condition.new([:call], {method_id: 'auth'}, {}, @result_config)
      @tp_filter = TpFilter.new(cond)
      filtered = @tps.reject { |tp| @tp_filter.block_it?(tp) }
      assert_equal [@user_tp], filtered
    end

    def test_filter_class_is_admin
      cond = Wrapper::Condition.new([:call], {}, {defined_class: 'Admin'}, @result_config)
      @tp_filter = TpFilter.new(cond)
      filtered = @tps.reject { |tp| @tp_filter.block_it?(tp) }
      assert_equal [], filtered
    end

    def test_filter_method_is_auth
      cond = Wrapper::Condition.new([:call], {}, {method_id: 'auth'}, @result_config)
      @tp_filter = TpFilter.new(cond)
      filtered = @tps.reject { |tp| @tp_filter.block_it?(tp) }
      assert_equal [@devise_tp, @warden_tp], filtered
    end

    def test_filter_method_is_new_class_is_devise
      cond = Wrapper::Condition.new([:call], {}, {defined_class: 'Devise', method_id: 'new'}, @result_config)
      @tp_filter = TpFilter.new(cond)
      filtered = @tps.reject { |tp| @tp_filter.block_it?(tp) }
      assert_equal [@devise_tp, @user_tp], filtered
    end

    def test_filter_class_is_devise_or_warden
      cond = Wrapper::Condition.new([:call], {}, {defined_class: 'Warden|User'}, @result_config)
      @tp_filter = TpFilter.new(cond)
      filtered = @tps.reject { |tp| @tp_filter.block_it?(tp) }
      assert_equal [@warden_tp, @user_tp], filtered
    end
  end
end
