class ApplicationController < ActionController::API
  include Response
  include JsonErrorsHandler
end
