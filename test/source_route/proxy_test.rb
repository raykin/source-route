require 'test_helper'

class SourceRoute::ProxyTest < Minitest::Test

  def setup
    @proxy = SourceRoute::Proxy.instance
    super
  end

end
