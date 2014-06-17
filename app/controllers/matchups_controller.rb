class MatchupsController < ApplicationController
	before_filter :verify_admin_user, only: [:show, :update, :save_week_outcomes]
  before_filter :verify_any_user, only: [:index]

  def index

    @week = Week.find(params[:week_id])
    @matchups = Matchup.where(week: @week)

    respond_to do | format |
      format.json {render :json => @matchups.to_json(include: [{ home_team: { only: [:name, :id] }}, away_team: {only: [:name, :id]}] ) }
    end
	end

  def show
    @matchup = Matchup.where(id: params[:id]).first

    respond_to do |format|
      format.json {render :json => @matchup.to_json(include: [{ home_team: { only: [:name, :id] }}, away_team: {only: [:name, :id]}] ) }
    end
  end

  def update
    Rails.logger.debug("(MatchupsController.update) is admin")
    @matchup = Matchup.where(id: params[:id]).first

    # Todo setup the permitted attributes for Rails 4
    cleaned_params = matchups_params
    Rails.logger.debug("Cleaned Params: #{cleaned_params}")
    if @matchup.update_attributes(cleaned_params)
      respond_to do | format |
        format.json {render json: @matchup.to_json(include: [{ home_team: { only: [:name, :id] }}, away_team: {only: [:name, :id]}] )}
      end
    else
      respond_to do | format |
        format.json { render :json => [], :status => :internal_server_error }
      end
    end
  end

  def save_week_outcomes
    Rails.logger.debug("in save_week_outcomes method")
    @matchups = Matchup.where(week_id: params[:week_id])
    @picks_this_week = Pick.where(week_id: params[:week_id]) #also need to only select those that are valid/locked in


    @picks_this_week.each do |pick|
      @picked_matchup = Matchup.where(:home_team_id == pick.team_id || :away_team_id == pick.team_id).first

      if @picked_matchup.tie == true
        pick.pool_entry.knocked_out = true
        pick.save!
      elsif @picked_matchup.winning_team_id == pick.team_id
        # Send email message or give some other notification that a person will continue?
      elsif @picked_matchup.winning_team_id != pick.team_id
        pick.pool_entry.knocked_out = true
        pick.save!
      end
    end

    respond_to do |format|
      format.json {render :json => @picks_this_week.to_json(include: {pool_entry: {only: [:team_name]} } ) }
    end
  end

  private

    def matchups_params
      params.permit(:home_team_id, :away_team_id, :game_time, :week_id, :completed, :tie, :winning_team_id)
    end
end