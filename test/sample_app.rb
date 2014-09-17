# Dont change it, it's used for stardard test
# When add more complex test, update FakeApp
class SampleApp

  def initialize(cool=nil)
    @cool = cool if cool
  end

  def nonsense
  end

  def nonsense_with_params(param1 = nil)
    param2 = 5
  end

  # call it with SampleApp.new(:cool), then the instance var will be init before call it
  def nonsense_with_instance_var
  end
end
