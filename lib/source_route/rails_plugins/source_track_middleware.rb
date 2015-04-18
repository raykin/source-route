class SourceTrackMiddleware

  def initialize(app)
    SourceRoute.enable do
      defined_class 'ApplicationClass'
    end

    @app = app
  end

  def call(env)
    SourceRoute.output_html
    @app.call(env)
  end
end
