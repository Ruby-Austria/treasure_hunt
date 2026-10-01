class TargetQueue < ApplicationRecord
  validates :city, presence: true
  validates :country, presence: true
  validates :hunts_to_generate, numericality: { greater_than: 0 }

  scope :pending, -> { where(processed: false) }
  scope :by_priority, -> { order(priority: :desc, created_at: :asc) }
  scope :incomplete, -> { where("hunts_generated_count < hunts_to_generate") }

  # Check if target has ungenerated hunts
  def incomplete?
    hunts_generated_count < hunts_to_generate
  end

  # Mark target as fully processed
  def mark_processed!
    update!(processed: true, last_generated_at: Time.current)
  end

  # Increment generation count
  def increment_generated!
    increment!(:hunts_generated_count)
    update!(last_generated_at: Time.current)
    mark_processed! unless incomplete?
  end

  # Get next target for generation (highest priority, oldest first)
  def self.next_target
    pending.incomplete.by_priority.first
  end
end
