class Admin::HuntsController < Admin::BaseController
  before_action :set_hunt, only: [ :show, :edit, :update, :destroy ]

  def index
    @hunts = Hunt.order(created_at: :desc)
  end

  def show
  end

  def new
    @hunt = Hunt.new
  end

  def create
    @hunt = Hunt.new(hunt_params)

    if @hunt.save
      redirect_to admin_hunt_path(@hunt), notice: "Hunt was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @hunt.update(hunt_params)
      redirect_to admin_hunt_path(@hunt), notice: "Hunt was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @hunt.destroy
    redirect_to admin_hunts_path, notice: "Hunt was successfully deleted."
  end

  private

  def set_hunt
    @hunt = Hunt.includes(:tags, clues: :location).find(params[:id])
  end

  def hunt_params
    params.require(:hunt).permit(:name, :description, :status, :difficulty, :hunt_type, :price, :language, :tag_list, :completion_message, :treasure_location, :treasure_access_code, :treasure_hint, :treasure_claimed_at, :treasure_claimed_by, :treasure_image)
  end
end
