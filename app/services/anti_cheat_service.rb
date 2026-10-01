class AntiCheatService
  MAX_ACCURACY_METERS = 150
  MIN_CHECK_INTERVAL_SECONDS = 3

  Result = Struct.new(:ok?, :error, keyword_init: true)

  def initialize(adventure:, user:, latitude:, longitude:, accuracy: nil)
    @adventure = adventure
    @user = user
    @lat = latitude.to_f
    @long = longitude.to_f
    @accuracy = accuracy&.to_f
  end

  def call
    if @accuracy && @accuracy > MAX_ACCURACY_METERS
      return Result.new("ok?": false, error: "GPS signal too weak (±#{@accuracy.round}m). Move outdoors for better accuracy.")
    end

    if rate_limited?
      return Result.new("ok?": false, error: "Too many location checks. Wait a few seconds and try again.")
    end

    record_check!
    Result.new("ok?": true)
  end

  private

  def rate_limited?
    return false unless @adventure.last_check_at

    elapsed = (Time.current - @adventure.last_check_at).to_f
    elapsed < MIN_CHECK_INTERVAL_SECONDS
  end

  def record_check!
    @adventure.update_columns(
      last_check_lat: @lat,
      last_check_long: @long,
      last_check_at: Time.current
    )
  end
end
