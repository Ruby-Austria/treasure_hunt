class Admin::CluesController < Admin::BaseController
  before_action :set_clue, only: [ :show, :edit, :update, :destroy ]

  def index
    @clues = Clue.includes(:hunt, :location).order(created_at: :desc)
    @clues = @clues.where(hunt_id: params[:hunt_id]) if params[:hunt_id].present?
  end

  def show
  end

  def new
    @clue = Clue.new
    @clue.hunt_id = params[:hunt_id] if params[:hunt_id].present?
  end

  def create
    @clue = Clue.new(clue_params)

    if @clue.save
      redirect_to admin_clue_path(@clue), notice: "Clue was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @clue.update(clue_params)
      redirect_to admin_clue_path(@clue), notice: "Clue was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @clue.destroy
    redirect_to admin_clues_path, notice: "Clue was successfully deleted."
  end

  private

  def set_clue
    @clue = Clue.includes(:hunt, location: :tags).find(params[:id])
  end

  def clue_params
    params_hash = params.require(:clue).permit(:hunt_id, :location_id, :title, :description, :difficulty, :reasoning, :hints, :fun_fact)

    # Convert comma-separated hints string to array
    if params_hash[:hints].present? && params_hash[:hints].is_a?(String)
      params_hash[:hints] = params_hash[:hints].split(",").map(&:strip).reject(&:empty?)
    end

    params_hash
  end
end
