module JsonErrorsHandler
  extend ActiveSupport::Concern
  attr_reader :error

  class DriverLocationServerError < StandardError
    attr_reader :error_message

    def initialize(response=nil)
      error_message= response.try(:body)
      @error_message = JSON.parse(error_message) if error_message
    end
  end

  included do
    rescue_from StandardError, with: :internal_server_error

    rescue_from ActiveRecord::RecordNotFound, with: :not_found_error
    rescue_from ActionController::UnpermittedParameters, with: :bad_request_error

    rescue_from DriverLocationServerError, with: lambda { |exception| driver_location_server_error(exception.error_message) }
  end

  protected

  def driver_location_server_error(error)
    title = 'Driver Location Server doesn\'t answer'
    render_response(error, title, :internal_server_error)
  end

  def bad_request_error(error)
    title = 'Unpermitted parameters'
    render_response(error, title, :bad_request)
  end

  def not_found_error(error)
    title = 'Resource Not Found'
    render_response(error, title, :not_found)
  end

  def internal_server_error(error)
    title = 'Internal Server Error'
    render_response(error, title, :internal_server_error)
  end

  private

  def render_response(error, title, status)
    unless performed?
      errors = [{ title: title }.merge!(backtrace(error))]
      render status: status, json: json_errors(errors)
    end
  end

  def backtrace(error)
    backtrace = { backtrace: error.backtrace[0,10] } if Rails.env.development?
    backtrace || {}
  end

  def json_errors(errors)
    { errors: errors }
  end
end