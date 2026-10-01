class Admin::AttendeesController < Admin::BaseController
  def index
    @attendees = User.where(admin: false).order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    password = generate_password
    @user = User.new(attendee_params.merge(password: password, password_confirmation: password))

    if @user.save
      redirect_to admin_attendees_path, notice: "Attendee #{@user.email} created. Password: #{password}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def unflag
    @user = User.find(params[:id])
    @user.update!(flagged_at: nil, flag_reason: nil)
    redirect_to admin_root_path, notice: "#{@user.display_name} unflagged."
  end

  def destroy
    @user = User.find(params[:id])

    if @user.admin?
      redirect_to admin_attendees_path, alert: "Cannot delete admin users."
    else
      @user.destroy
      redirect_to admin_attendees_path, notice: "Attendee removed.", status: :see_other
    end
  end

  def bulk_new
  end

  def bulk_create
    emails = params[:emails].to_s.split(/[\n,;]+/).map(&:strip).reject(&:blank?).uniq
    results = { created: [], errors: [] }

    emails.each do |email|
      password = generate_password
      user = User.new(email: email.downcase, password: password, password_confirmation: password)

      if user.save
        results[:created] << { email: user.email, password: password }
      else
        results[:errors] << { email: email, errors: user.errors.full_messages }
      end
    end

    @results = results
    render :bulk_results
  end

  private

  def attendee_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end

  def generate_password
    SecureRandom.alphanumeric(10)
  end
end
