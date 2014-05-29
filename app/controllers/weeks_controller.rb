class WeeksController < ApplicationController
  before_action :require_user
  before_action :require_admin, only: [:update, :destroy, :create]

  def index
    if is_any_user
    	@weeks = Week.where(season_id: params[:season_id])
    	respond_to do | format |
    		format.json { render json: @weeks }
    	end
    else
      Rails.logger.debug("(WeeksController.index) unauthorized")
      respond_to do | format |
        format.json { render :json => [], :status => :unauthorized }
      end
    end
  end

  def close_week_for_picks

  end
end