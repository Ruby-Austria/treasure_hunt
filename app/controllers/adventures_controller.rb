class AdventuresController < ApplicationController
  before_action :require_login
  before_action :set_adventure, only: [ :show, :check_location, :claim_clue, :increment_hint_usage, :abandon ]
  before_action :set_adventure_admin, only: [ :force_claim ]
  before_action :require_ownership, only: [ :show, :check_location, :claim_clue, :increment_hint_usage, :abandon ]

  def create
    @hunt = Hunt.approved.find(params[:hunt_id])

    unless @hunt.clues.exists?
      redirect_to hunt_path(@hunt), alert: "This hunt has no clues yet and cannot be started."
      return
    end

    existing = current_user.adventures.find_by(hunt: @hunt, status: :in_progress)
    if existing
      redirect_to adventure_path(existing), notice: "You already have an active adventure for this hunt!"
      return
    end

    @adventure = current_user.adventures.build(hunt: @hunt, status: :in_progress)

    if @adventure.save
      @adventure.reload
      unless @adventure.current_clue
        redirect_to hunt_path(@hunt), alert: "Could not start adventure: No clues available for this hunt."
        return
      end
      redirect_to adventure_path(@adventure), notice: "Adventure started! Good luck!"
    else
      redirect_to hunt_path(@hunt), alert: "Could not start adventure: #{@adventure.errors.full_messages.join(', ')}"
    end
  end

  def show
    @adventure.ensure_current_clue!
    @adventure.reload
    @current_clue = @adventure.current_clue
    @all_solved = @adventure.all_clues_solved?
    @solved_clues = Clue.includes(:location).where(id: @adventure.solved_clue_ids).order(:id) if @adventure.solved_clue_ids.any?
  end

  def check_location
    unless params[:latitude].present? && params[:longitude].present?
      render json: { error: "Latitude and longitude are required" }, status: :bad_request
      return
    end

    anti_cheat = AntiCheatService.new(
      adventure: @adventure,
      user: current_user,
      latitude: params[:latitude],
      longitude: params[:longitude],
      accuracy: params[:accuracy]
    ).call

    unless anti_cheat.ok?
      render json: { error: anti_cheat.error }, status: :forbidden
      return
    end

    current_clue = @adventure.current_clue
    unless current_clue&.location
      render json: { error: "No clue to solve" }, status: :bad_request
      return
    end

    result = LocationCheckService.new(
      user_lat: params[:latitude],
      user_long: params[:longitude],
      clue_location: current_clue.location,
      unlock_radius: current_clue.radius,
      adventure: @adventure
    ).call

    response = {
      can_claim: result[:can_claim],
      claim_token: result[:claim_token],
      temperature: result[:temperature]
    }

    if admin?
      response.merge!(
        distance: result[:distance],
        unlock_radius: result[:unlock_radius],
        user_location: result[:user_location],
        clue_location: result[:clue_location],
        user_accuracy: params[:accuracy].to_f
      )
    end

    render json: response
  rescue StandardError => e
    Rails.logger.error("check_location error: #{e.class} - #{e.message}")
    render json: { error: "An error occurred while checking location." }, status: :internal_server_error
  end

  def claim_clue
    service = ClaimClueService.new(adventure: @adventure, claim_token: params[:claim_token], force: false).call

    if service.success?
      render json: { success: true, all_solved: @adventure.all_clues_solved? }
    else
      render json: { error: service.error }, status: :unauthorized
    end
  rescue StandardError => e
    Rails.logger.error("claim_clue error: #{e.class} - #{e.message}")
    render json: { error: "An error occurred while claiming the clue." }, status: :internal_server_error
  end

  def force_claim
    unless admin?
      render json: { error: "Unauthorized. Admin access required." }, status: :unauthorized
      return
    end

    service = ClaimClueService.new(adventure: @adventure, claim_token: nil, force: true).call

    if service.success?
      render json: { success: true, all_solved: @adventure.all_clues_solved? }
    else
      render json: { error: service.error || "Could not force claim clue" }, status: :unauthorized
    end
  rescue StandardError => e
    Rails.logger.error("force_claim error: #{e.class} - #{e.message}")
    render json: { error: "An error occurred while force claiming the clue." }, status: :internal_server_error
  end

  def abandon
    unless @adventure.in_progress?
      redirect_to adventure_path(@adventure), alert: "Only in-progress adventures can be abandoned."
      return
    end

    @adventure.update!(status: :abandoned, current_clue_id: nil)
    redirect_to hunt_path(@adventure.hunt), notice: "Adventure abandoned.", status: :see_other
  end

  def increment_hint_usage
    @adventure.reload
    service = IncrementHintUsageService.new(adventure: @adventure).call

    if service.success?
      render json: {
        success: true,
        hints_used: service.hints_used,
        revealed_hints: service.revealed_hints,
        hint: service.hint,
        next_hint_available_at: service.next_hint_available_at,
        message: service.hint.nil? ? "All hints have been revealed" : nil
      }.compact
    elsif service.cooldown_remaining
      render json: {
        error: service.error,
        cooldown_remaining: service.cooldown_remaining,
        cooldown_remaining_minutes: service.cooldown_remaining_minutes,
        next_hint_available_at: service.next_hint_available_at
      }, status: :too_many_requests
    else
      render json: { error: service.error }, status: :bad_request
    end
  rescue StandardError => e
    Rails.logger.error("increment_hint_usage error: #{e.class} - #{e.message}")
    render json: { error: "An error occurred while revealing a hint." }, status: :internal_server_error
  end

  private

  def set_adventure
    scope = admin? ? Adventure : current_user.adventures
    @adventure = scope.includes(hunt: [ :tags, :clues ], current_clue: :location).find(params[:id])
  end

  def set_adventure_admin
    @adventure = Adventure.includes(hunt: [ :tags, :clues ], current_clue: :location).find(params[:id])
  end

  def require_ownership
    return if @adventure.user == current_user || admin?

    respond_to do |format|
      format.html { redirect_to root_path, alert: "You don't have access to this adventure." }
      format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
    end
  end
end
