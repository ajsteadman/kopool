require 'spec_helper'

RSpec.describe Pick, type: :model do

  it { should belong_to :week }
  it { should belong_to :nfl_team }
  it { should belong_to :pool_entry }
  it { should validate_uniqueness_of(:pool_entry_id).scoped_to(:week_id)}

  it { should validate_presence_of :team_id }
  it { should validate_presence_of :matchup_id }
  it { should validate_presence_of :pool_entry_id }
  it { should validate_presence_of :week_id }


  it "should allow more than one pick for two different pool entries" do
    @user = create(:user)
    @season = create(:season)
    @week16 = Week.create(week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: @season)
    @week17 = Week.create(week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: @season)
    @web_state = create(:web_state, week_id: @week16.id, season_id: @season.id)
    @team1 = FactoryBot.create(:nfl_team)
    @team2 = FactoryBot.create(:nfl_team)
    @monday_matchup = Matchup.create(game_time: DateTime.new(2017,8,14,15,00), week_id: @week16.id, home_team_id: @team1.id, away_team_id: @team2.id)

    @pool_entry_1 = FactoryBot.create(:pool_entry, team_name: "Losers did not pick", season: @season, user: @user)
    @pool_entry_2 = FactoryBot.create(:pool_entry, team_name: "We dont matter", knocked_out: true, season: @season, user: @user)
    @pick1 = FactoryBot.create(:pick, pool_entry: @pool_entry_1, week: @week16, nfl_team: @monday_matchup.away_team, matchup: @monday_matchup)
    @pick2 = FactoryBot.create(:pick, pool_entry: @pool_entry_2, week: @week16, nfl_team: @monday_matchup.home_team, matchup: @monday_matchup)

    expect(Pick.count).to eq(2)
  end


  it "should not allow more than one pick for same pool entry" do
    @user = create(:user)
    @season = create(:season)
    @week16 = Week.create(week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: @season)
    @week17 = Week.create(week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: @season)
    @web_state = create(:web_state, week_id: @week16.id, season_id: @season.id)
    @team1 = FactoryBot.create(:nfl_team)
    @team2 = FactoryBot.create(:nfl_team)
    @monday_matchup = Matchup.create(game_time: DateTime.new(2017,8,14,15,00), week_id: @week16.id, home_team_id: @team1.id, away_team_id: @team2.id)

    @pool_entry_1 = FactoryBot.create(:pool_entry, team_name: "We are just one pool entry", season: @season, user: @user)
    @pick1 = FactoryBot.create(:pick, pool_entry: @pool_entry_1, week: @week16, nfl_team: @monday_matchup.away_team, matchup: @monday_matchup)

    expect {
      FactoryBot.create(:pick, pool_entry: @pool_entry_1, week: @week16, nfl_team: @monday_matchup.home_team, matchup: @monday_matchup)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "does not allow you to save a pick without a matchup" do
    @user = create(:user)
    @season = create(:season)
    @week16 = Week.create(week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: @season)
    @week17 = Week.create(week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: @season)
    @web_state = create(:web_state, week_id: @week16.id, season_id: @season.id)
    @team1 = FactoryBot.create(:nfl_team)
    @team2 = FactoryBot.create(:nfl_team)
    @monday_matchup = Matchup.create(game_time: DateTime.new(2017,8,14,15,00), week_id: @week16.id, home_team_id: @team1.id, away_team_id: @team2.id)
    @pool_entry_1 = FactoryBot.create(:pool_entry, team_name: "We are just one pool entry", season: @season, user: @user)

    expect {
      @pick1 = FactoryBot.create(:pick, pool_entry: @pool_entry_1, week: @week16, nfl_team: @monday_matchup.away_team)
      }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "Verifies that the pick.team_id is either the home OR away team of that matchup" do
    @user = create(:user)
    @season = create(:season)
    @week16 = Week.create(week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: @season)
    @web_state = create(:web_state, week_id: @week16.id, season_id: @season.id)
    @team1 = FactoryBot.create(:nfl_team)
    @team2 = FactoryBot.create(:nfl_team)
    @team3 = FactoryBot.create(:nfl_team)
    @monday_matchup = Matchup.create(game_time: DateTime.new(2017,8,14,15,00), week_id: @week16.id, home_team_id: @team1.id, away_team_id: @team2.id)

    @pool_entry_1 = FactoryBot.create(:pool_entry, team_name: "Our pick will be valid", season: @season, user: @user)
    @pool_entry_2 = FactoryBot.create(:pool_entry, team_name: "Our pick will not be valid", knocked_out: true, season: @season, user: @user)
    @pick1 = FactoryBot.create(:pick, pool_entry: @pool_entry_1, week: @week16, nfl_team: @monday_matchup.away_team, matchup: @monday_matchup)
    expect {
        @pick2 = FactoryBot.create(:pick, pool_entry: @pool_entry_2, week: @week16, nfl_team: @team3, matchup: @monday_matchup)
      }.to raise_error(ActiveRecord::RecordInvalid)

    expect(Pick.count).to eq(1)
  end


  it "should record auto_picked when auto-picked" do
    @season = create(:season)
    @week16 = Week.create(week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: @season)
    @week17 = Week.create(week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: @season)
    @web_state = create(:web_state, week_id: @week16.id, season_id: @season.id)
    @team1 = FactoryBot.create(:nfl_team)
    @team2 = FactoryBot.create(:nfl_team)
    @monday_matchup = Matchup.create(game_time: DateTime.new(2017,8,14,15,00), week_id: @week16.id, home_team_id: @team1.id, away_team_id: @team2.id)

    @pool_entry_nopick1 = FactoryBot.create(:pool_entry, team_name: "Losers did not pick", season: @season)
    @pool_entry_knocked = FactoryBot.create(:pool_entry, team_name: "We dont matter", knocked_out: true, season: @season)
    @pool_entry_pick1 = FactoryBot.create(:pool_entry, season: @season)
    @pick1 = FactoryBot.create(:pick, pool_entry: @pool_entry_pick1, week: @week16, nfl_team: @monday_matchup.away_team, matchup: @monday_matchup)

    @week16.move_to_next_week!

    expect(Pick.where(auto_picked: true).count).to eq(1)
  end

  it "can be changed if not locked in" do
    @user = create(:user)
    @season = create(:season)
    @week16 = Week.create(week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: @season)
    @week17 = Week.create(week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: @season)
    @web_state = create(:web_state, week_id: @week16.id, season_id: @season.id)
    @team1 = FactoryBot.create(:nfl_team)
    @team2 = FactoryBot.create(:nfl_team)
    @monday_matchup = Matchup.create(game_time: DateTime.new(2017,8,14,15,00), week_id: @week16.id, home_team_id: @team1.id, away_team_id: @team2.id)

    @pool_entry_1 = FactoryBot.create(:pool_entry, team_name: "We not locked in", season: @season, user: @user)
    @pick1 = FactoryBot.create(:pick, pool_entry: @pool_entry_1, week: @week16, nfl_team: @monday_matchup.away_team, matchup: @monday_matchup)
    expect(Pick.last.nfl_team).to eq(@monday_matchup.away_team)
    expect {
      @pick1.nfl_team = @monday_matchup.home_team
      @pick1.save!
    }.not_to raise_error
    expect(Pick.last.nfl_team).to eq(@monday_matchup.home_team)
  end

  it "cannot be changed if locked in" do
    @user = create(:user)
    @season = create(:season)
    @week16 = Week.create(week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: @season)
    @week17 = Week.create(week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: @season)
    @web_state = create(:web_state, week_id: @week16.id, season_id: @season.id)
    @team1 = FactoryBot.create(:nfl_team)
    @team2 = FactoryBot.create(:nfl_team)
    @monday_matchup = Matchup.create(game_time: DateTime.new(2017,8,14,15,00), week_id: @week16.id, home_team_id: @team1.id, away_team_id: @team2.id)

    @pool_entry_1 = FactoryBot.create(:pool_entry, team_name: "We locked in", season: @season, user: @user)
    @pick1 = FactoryBot.create(:pick, pool_entry: @pool_entry_1, week: @week16, nfl_team: @monday_matchup.away_team, matchup: @monday_matchup)
    expect(Pick.last.nfl_team).to eq(@monday_matchup.away_team)
    @pick1.update_attributes(locked_in: true)
    expect {
      @pick1.nfl_team = @monday_matchup.home_team
      @pick1.save!
    }.to raise_error(ActiveRecord::RecordInvalid)
    expect(Pick.last.nfl_team).to eq(@monday_matchup.away_team)
  end

end
