class DashboardController < ApplicationController
  before_action :require_login

  def index
    @team = current_user.team
    @active_adventures = current_user.adventures
                                     .in_progress
                                     .includes(hunt: :clues)
                                     .order(updated_at: :desc)
    @completed_adventures = current_user.adventures
                                        .where(status: :completed)
                                        .includes(hunt: :clues)
                                        .order(updated_at: :desc)
    @hunts = Hunt.approved.where(id: Clue.select(:hunt_id)).includes(:clues).order(:name)
    @leaderboard = build_leaderboard_widget
  end

  private

  def build_leaderboard_widget
    # Compact leaderboard: top 5 across all hunts combined
    entries = {}

    Hunt.approved.where(id: Clue.select(:hunt_id)).includes(:clues).find_each do |hunt|
      Adventure.where(hunt: hunt, status: [ :in_progress, :completed ])
               .includes(user: :team)
               .find_each do |adventure|
        team = adventure.user.team
        key = team ? "team_#{team.id}" : "user_#{adventure.user_id}"

        existing = entries[key]
        solved = adventure.solved_clue_ids.count

        if existing.nil?
          entries[key] = {
            name: team ? team.name : adventure.user.display_name,
            team: team.present?,
            total_solved: solved,
            completed_hunts: adventure.completed? ? 1 : 0
          }
        else
          existing[:total_solved] += solved
          existing[:completed_hunts] += 1 if adventure.completed?
        end
      end
    end

    entries.values
           .sort_by { |e| [ -e[:completed_hunts], -e[:total_solved] ] }
           .first(5)
  end
end
