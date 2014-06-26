require "source_route/version"
require "source_route/wrapper"

module SourceRoute
  extend self

  def enable(str_or_reg)
    Wrapper.new(str_or_reg).engine_instance.enable
  end
end
