class PagesController < ApplicationController
  def index
    if logged_in?
      redirect_to dashboard_path
    else
      @hunts = Hunt.approved.includes(:clues).order(:name)
    end
  end
end
