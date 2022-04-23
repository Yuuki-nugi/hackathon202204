module Api
  module V1
    class ProductsController < ApplicationController
      def index
        render json: { status: 'success', message: 'health check'}
      end
    end
  end
end
