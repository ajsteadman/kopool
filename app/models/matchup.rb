class Matchup < ApplicationRecord

  # may have to specify the fk
  belongs_to :home_team, class_name: "NflTeam"
  belongs_to :away_team, class_name: "NflTeam"
  belongs_to :week
  has_many :picks

  validates :week, :home_team, :away_team, presence: true


  def self.handle_matchup_outcome!(matchup_id)
    @matchup = Matchup.find_by(id: matchup_id)
    @this_matchups_picks = @matchup.picks
    if @this_matchups_picks.empty?
      @matchup.completed = true
      @matchup.save!
    else
      @this_matchups_picks.each do |pick|
        if @matchup.tie == true
          Matchup.handle_tie_game(@matchup, pick)
        elsif @matchup.winning_team_id == pick.team_id
          Matchup.handle_winning_outcome(@matchup, pick)
        elsif @matchup.winning_team_id != pick.team_id
          Matchup.handle_losing_outcome(@matchup, pick)
        end
      end
    end
  end

  def self.revert_matchup_outcome!(matchup_id)
    @matchup = Matchup.includes(:picks).find_by(id: matchup_id)

    return unless @matchup

    @matchup.update!(completed: false, tie: nil, winning_team_id: nil)

    @matchup.picks.each do |pick|
      pick.pool_entry.update!(knocked_out: false, knocked_out_week_id: nil)
    end
  end

private

  def self.handle_tie_game(matchup, pick)
    pick.pool_entry.knocked_out = true
    pick.pool_entry.knocked_out_week_id = matchup.week_id
    pick.save!
    matchup.completed = true
    matchup.save!
  end

  def self.handle_winning_outcome(matchup, pick)
    # Send email message or give some other notification that a person will continue?
    matchup.completed = true
    matchup.save!
  end

  def self.handle_losing_outcome(matchup, pick)
    pick.pool_entry.knocked_out = true
    pick.pool_entry.knocked_out_week_id = matchup.week_id
    pick.save!
    matchup.completed = true
    matchup.save!
  end

end
