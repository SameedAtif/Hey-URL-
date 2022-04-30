# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include ExceptionHandler
      include BaseHandler

      protected

      def index
        render json: collection
      end

      def collection
        @collection ||= model.all
      end
    end
  end
end
