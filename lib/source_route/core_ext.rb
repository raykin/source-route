class Object
  def source_route_display
    # to_s # cause crash?
    self
  end
end

class NilClass
  def source_route_display
    inspect
  end
end

class Symbol
  def source_route_display
    inspect
  end
end

class String
  def source_route_display
    eql?('') ? inspect : to_s
  end
end
