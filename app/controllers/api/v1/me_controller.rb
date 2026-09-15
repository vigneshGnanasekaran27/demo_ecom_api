module Api
  module V1
    class MeController < BaseController
      before_action :authenticate_request!

      # GET /api/v1/me
      def show
        render json: { data: UserSerializer.new(current_user).as_json }
      end
    end
  end
end
