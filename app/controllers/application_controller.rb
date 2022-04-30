# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ExceptionHandler

  add_flash_types :error, :warning, :success
  helper_method :domain_name

  private

  def domain_name
    root_url
  end
end
