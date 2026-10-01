class LocationCheckService
  def initialize(user_lat:, user_long:, clue_location:, unlock_radius: nil, adventure: nil)
    raise ArgumentError, "clue_location cannot be nil" if clue_location.nil?
    raise ArgumentError, "clue_location must have lat and long" if clue_location.lat.nil? || clue_location.long.nil?

    @user_lat = user_lat.to_f
    @user_long = user_long.to_f
    @clue_lat = clue_location.lat.to_f
    @clue_long = clue_location.long.to_f
    @unlock_radius = unlock_radius || 50
    @adventure = adventure
  end

  def call
    distance = calculate_distance
    can_claim = distance <= @unlock_radius
    claim_token = store_claim_token if can_claim && @adventure

    {
      can_claim: can_claim,
      claim_token: claim_token,
      distance: distance.round(2),
      unlock_radius: @unlock_radius,
      temperature: temperature_message(distance),
      user_location: { lat: @user_lat, long: @user_long },
      clue_location: { lat: @clue_lat, long: @clue_long }
    }
  end

  private

  def store_claim_token
    token = SecureRandom.hex(32)
    @adventure.reload
    @adventure.update(
      current_clue_claim_token: token,
      current_clue_claim_token_expires_at: 2.minutes.from_now
    )
    token
  rescue ActiveRecord::RecordNotFound, ActiveRecord::StaleObjectError => e
    Rails.logger.error("Failed to store claim token for adventure #{@adventure.id}: #{e.message}")
    nil
  end

  def calculate_distance
    DistanceCalculator.haversine(@user_lat, @user_long, @clue_lat, @clue_long)
  end

  def temperature_message(distance)
    case distance
    when 0..50   then { message: "🔥 You're very close! Time to claim!", level: "hot" }
    when 50..100 then { message: "🟠 You're warm! Look around carefully.", level: "warm" }
    when 100..200 then { message: "🟡 Getting closer! Keep going.", level: "closer" }
    else { message: "🔵 Keep searching — you're far away.", level: "cold" }
    end
  end
end
