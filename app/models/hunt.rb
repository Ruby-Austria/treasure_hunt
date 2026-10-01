class Hunt < ApplicationRecord
  # Tagging - must be defined before enums to avoid method conflicts
  acts_as_taggable_on :tags

  enum :status, {
    draft: 1,
    approved: 2,
    archived: 3
  }

  enum :difficulty, {
    easy: 1,
    moderate: 2,
    medium: 3,
    challenging: 4,
    hard: 5
  }

  enum :hunt_type, {
    for_fun: 1,
    reward: 2
  }

  validates :name, presence: true
  validates :status, presence: true
  validates :difficulty, presence: true
  validates :hunt_type, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :language, presence: true

  # Associations — adventures before clues to avoid FK violation on destroy
  has_many :adventures, dependent: :destroy
  has_many :users, through: :adventures
  has_many :clues, dependent: :destroy
  has_many :locations, through: :clues

  has_one_attached :treasure_image

  def treasure_claimed?
    treasure_claimed_at.present?
  end

  def has_treasure?
    treasure_location.present?
  end
end
