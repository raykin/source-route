class NilClass
  def nature_value
    nil
  end

end

class String
  def nature_value
    self
  end
end

class Class
  def nature_value
    self.name
  end
end

class Module
  def nature_value
    self.name
  end
end

class Symbol
  def nature_value
    to_s
  end
end
