class Location < ApplicationRecord
  # Tagging - must be defined before enums to avoid method conflicts
  acts_as_taggable_on :tags

  enum :difficulty, {
    easy: 1,
    moderate: 2,
    medium: 3,
    challenging: 4,
    hard: 5
  }

  enum :verification_state, {
    ai_generated: 0,
    auto_verified: 1,
    human_verified: 2
  }, default: :ai_generated

  validates :lat, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :long, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :name, presence: true
  validates :country, presence: true
  validates :city, presence: true
  validates :difficulty, presence: true
  validates :unlock_radius, numericality: { greater_than: 0 }, allow_nil: true
  validates :confidence_score, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }, allow_nil: true

  # Associations
  has_many :clues, dependent: :destroy
  has_many :hunts, through: :clues

  # Check if player is within location radius
  # @param player_lat [Float]
  # @param player_lng [Float]
  # @return [Boolean]
  def within_radius?(player_lat, player_lng)
    distance = DistanceCalculator.haversine(player_lat, player_lng, lat, long)
    distance <= (unlock_radius || 200)
  end

  # Update location based on successful player claim
  # Implements community learning - refine location over time
  # @param player_lat [Float]
  # @param player_lng [Float]
  def update_from_player_claim(player_lat, player_lng)
    new_count = (usage_count || 0) + 1
    attrs = { usage_count: new_count }

    # Calculate rolling average
    if avg_player_lat.nil? || avg_player_lng.nil?
      attrs[:avg_player_lat] = player_lat
      attrs[:avg_player_lng] = player_lng
    else
      # Weighted average (80% existing, 20% new claim)
      attrs[:avg_player_lat] = (avg_player_lat * 0.8) + (player_lat * 0.2)
      attrs[:avg_player_lng] = (avg_player_lng * 0.8) + (player_lng * 0.2)

      # Increase confidence as more players verify
      if new_count >= 5 && confidence_score < 0.9
        attrs[:confidence_score] = [ confidence_score + 0.05, 0.95 ].min
      end

      # Auto-verify after 10 successful claims
      attrs[:verification_state] = :auto_verified if new_count >= 10 && ai_generated?
    end

    update!(attrs)
  end
end
