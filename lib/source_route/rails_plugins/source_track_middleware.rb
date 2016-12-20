module Rack
  class SourceRoute

    def initialize(app, opts={})
      @opts = opts
      @app = app
    end

    def call(env)
      ::SourceRoute.enable do
        # defined_class 'Cors'
        # method_id opts[:method_id] # will crashed
        method_id 'render'
        full_feature
      end

      @app.call(env)
    end

  end
end
