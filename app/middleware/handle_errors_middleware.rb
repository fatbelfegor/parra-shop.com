class HandleErrorsMiddleware

  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionController::BadRequest
    ApplicationController.action(:page404).call(env)
  end
end