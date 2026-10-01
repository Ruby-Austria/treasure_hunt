class Clue < ApplicationRecord
  belongs_to :hunt
  belongs_to :location

  enum :difficulty, {
    easy: 1,
    moderate: 2,
    medium: 3,
    challenging: 4,
    hard: 5
  }

  validates :hunt_id, uniqueness: { scope: :location_id, message: "can only have one clue per location in a hunt" }
  validates :difficulty, presence: true

  # Delegations to Location
  delegate :unlock_radius, to: :location, prefix: false
  alias_method :radius, :unlock_radius

  delegate :city, to: :location, prefix: false
  delegate :country, to: :location, prefix: false
  delegate :lat, to: :location, prefix: false
  delegate :long, to: :location, prefix: false
  # Tags are delegated from location via acts-as-taggable-on
  def tags
    location.tags.map(&:name)
  end
end
