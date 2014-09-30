# Dont change it, it's used for stardard test
# When add more complex test, update FakeApp
class SampleApp

  def initialize(sample=nil)
    @sample = sample if sample
  end

  def nonsense
  end

  def nonsense_with_params(param1 = nil)
    param2 = 5
  end

  # call it with SampleApp.new(:cool), then the instance var will be init before call it
  def nonsense_with_instance_var
    nonsense
  end

  def init_cool_app
    CoolApp.new.foo
  end

  class CoolApp
    def initialize
      @cool = ['test', 'data']
      # todo: cant display on html easily
      @cool_hash = {first: :run, second: :halt, third: :stop}
      cool_in_init = 'init data in cool app'

    end

    def foo
      cool_in_foo = 'foo data'
      @cool_ins_after = 'will shown in result?'
    end
  end
end
