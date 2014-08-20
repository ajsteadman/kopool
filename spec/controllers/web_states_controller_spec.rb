require 'spec_helper'

describe Admin::WebStatesController do
  describe "PUT update" do

    before do
      @season = create(:season)
      @week16 = Week.create(week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: @season)
      @week17 = Week.create(week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: @season)
      @web_state = create(:web_state, week_id: @week16.id)
      @admin = create(:admin)
      @regular_guy = create(:user)

    end

    it "should not allow non-admin to update" do
      sign_in :user, @regular_guy
      params = { id: 1, current_week: @week17, format: :json }
      put :update, params
      expect(response.status).to eq(Rack::Utils.status_code(:unauthorized))
    end

    it "should allow admin to update" do
      sign_in :user, @admin
      params = { id: 1, current_week: @week17, format: :json }
      put :update, params
      expect(response.status).to eq(Rack::Utils.status_code(:ok))
    end
  end
end