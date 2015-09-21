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
      super
    end

    def test_filter_method_not_auth
      cond = Config.new
      cond.negatives[:method_id] = 'auth'
      @tp_filter = TpFilter.new(cond)
      filtered = @tps.reject { |tp| @tp_filter.block_it?(tp) }
      assert_equal [@user_tp], filtered
    end

    def test_filter_class_is_admin
      cond = Config.new
      cond.positives[:defined_class] = 'Admin'
      @tp_filter = TpFilter.new(cond)
      filtered = @tps.reject { |tp| @tp_filter.block_it?(tp) }
      assert_equal [], filtered
    end

    def test_filter_method_is_auth
      cond = Config.new
      cond.positives[:method_id] = 'auth'
      @tp_filter = TpFilter.new(cond)
      filtered = @tps.reject { |tp| @tp_filter.block_it?(tp) }
      assert_equal [@devise_tp, @warden_tp], filtered
    end

    def test_filter_method_is_new_class_is_devise
      cond = Config.new
      cond.positives[:defined_class] = 'Devise'
      cond.positives[:method_id] = 'new'
      @tp_filter = TpFilter.new(cond)
      filtered = @tps.reject { |tp| @tp_filter.block_it?(tp) }
      assert_equal [@devise_tp, @user_tp], filtered
    end

    def test_filter_class_is_devise_or_warden
      cond = Config.new
      cond.positives[:defined_class] = 'Warden|User'
      @tp_filter = TpFilter.new(cond)
      filtered = @tps.reject { |tp| @tp_filter.block_it?(tp) }
      assert_equal [@warden_tp, @user_tp], filtered
    end
  end
end
