module Rack
  class SourceRoute

    def initialize(app, opts={})
      @opts = opts
      if @opts.present?
        ::SourceRoute.enable do
          # defined_class 'Cors'
          # method_id opts[:method_id] # will crashed
          method_id 'resource_for_path'
          full_feature
        end
      end
      @app = app
    end

    def call(env)
      @app.call(env)
    end

  end
end
