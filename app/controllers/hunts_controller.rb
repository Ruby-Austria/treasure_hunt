class HuntsController < ApplicationController
  def show
    @hunt = Hunt.approved.includes(:tags, :clues).find_by(id: params[:id])

    unless @hunt
      redirect_to root_path, alert: "Hunt not found or not available."
      return
    end

    if logged_in?
      @current_adventures = current_user.adventures.includes(hunt: :clues).where(hunt: @hunt, status: :in_progress).order(created_at: :desc)
      @past_adventures_scope = current_user.adventures.includes(hunt: :clues).where(hunt: @hunt, status: :completed).order(created_at: :desc)
      @past_adventures_count = @past_adventures_scope.count
      @past_page = [ (params[:past_page] || 1).to_i, 1 ].max
      @past_per_page = 5
      @past_adventures = @past_adventures_scope.offset((@past_page - 1) * @past_per_page).limit(@past_per_page)
      @past_total_pages = (@past_adventures_count.to_f / @past_per_page).ceil
      @latest_adventure = @current_adventures.first
    end
  end
end
