class Admin::TeamsController < Admin::BaseController
  def index
    @teams = Team.includes(:members).order(created_at: :desc)
  end

  def show
    @team = Team.includes(:members).find(params[:id])
  end
end
