class ApplicationController < ActionController::API
  helper_method :current_user

  rescue_from Exception,                           with: :render_unknown_error
  rescue_from ActionController::ParameterMissing,  with: :render_parameter_missing
  rescue_from ActiveRecord::RecordInvalid,         with: :render_record_invalid
  rescue_from ActiveRecord::RecordNotFound,        with: :render_not_found

  private

  def current_user
    @current_user ||= User.find(params[:id])
  end

  def render_unknown_error(exception)
    return render_not_found(exception) if exception.cause.is_a?(ActiveRecord::RecordNotFound)

    logger.info(exception)
    render json: json_error(exception, I18n.t('api.errors.server')),
           status: :internal_server_error
  end

  def render_parameter_missing(exception)
    logger.info(exception)
    render json: json_error(exception, I18n.t('api.errors.missing_param')),
           status: :unprocessable_entity
  end

  def render_record_invalid(exception)
    logger.info(exception)
    render json: { errors: exception.record.errors.as_json },
           status: :bad_request
  end

  def render_not_found(exception)
    logger.info(exception)
    render json: json_error(exception, I18n.t('api.errors.not_found')),
           status: :not_found
  end

  def json_error(exception, title)
    {
      error: title,
      detail: exception.message
    }
  end
end
