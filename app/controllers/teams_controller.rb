class TeamsController < ApplicationController
  before_action :require_login
  before_action :set_team, only: %i[show leave regenerate_code]

  def show
  end

  def new
    if current_user.team
      redirect_to team_path, notice: "You are already in a team."
      return
    end
    @team = Team.new
  end

  def create
    if current_user.team
      redirect_to team_path, alert: "You are already in a team."
      return
    end

    @team = Team.new(team_params)
    if @team.save
      @team.members << current_user
      redirect_to team_path, notice: "Team created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def join
    if current_user.team
      redirect_to team_path, alert: "You must leave your current team first."
      return
    end

    @team = Team.find_by(invite_code: params[:invite_code]&.strip&.upcase)
    unless @team
      redirect_to new_team_path, alert: "Invalid invite code."
      return
    end

    @team.members << current_user
    sync_team_progress(@team, current_user)
    redirect_to team_path, notice: "Joined #{@team.name}!"
  end

  def leave
    if @team.has_completed_adventures?
      redirect_to team_path, alert: "You cannot leave a team that has claimed treasure."
      return
    end

    current_user.team_membership.destroy
    @team.destroy if @team.members.reload.empty?
    redirect_to dashboard_path, notice: "You left the team."
  end

  def regenerate_code
    @team.regenerate_invite_code!
    redirect_to team_path, notice: "New invite code generated."
  end

  private

  def set_team
    @team = current_user.team
    redirect_to new_team_path, alert: "You are not in a team." unless @team
  end

  def team_params
    params.require(:team).permit(:name)
  end

  def sync_team_progress(team, new_member)
    team.members.where.not(id: new_member.id).each do |member|
      member.adventures.in_progress.find_each do |teammate_adventure|
        adventure = new_member.adventures.find_by(hunt_id: teammate_adventure.hunt_id, status: :in_progress)
        next unless adventure

        new_solved = (teammate_adventure.solved_clue_ids | adventure.solved_clue_ids).uniq
        next if new_solved.sort == adventure.solved_clue_ids.sort

        adventure.update!(
          solved_clue_ids: new_solved,
          current_clue_id: find_next_unsolved(adventure.hunt, new_solved)
        )
        complete_if_done(adventure)
      end
    end
  end

  def find_next_unsolved(hunt, solved_ids)
    available = hunt.clues.order(:id).pluck(:id) - solved_ids
    available.first
  end

  def complete_if_done(adventure)
    return unless adventure.all_clues_solved?

    adventure.update!(status: :completed, current_clue_id: nil)
  end
end
