class Admin::LocationsController < Admin::BaseController
  before_action :set_location, only: [ :show, :edit, :update, :destroy ]

  def index
    @locations = Location.order(created_at: :desc)
  end

  def show
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      redirect_to admin_location_path(@location), notice: "Location was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @location.update(location_params)
      redirect_to admin_location_path(@location), notice: "Location was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to admin_locations_path, notice: "Location was successfully deleted."
  end

  private

  def set_location
    @location = Location.includes(:tags).find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :lat, :long, :description, :reasoning, :country, :city, :difficulty, :unlock_radius, :tag_list)
  end
end
