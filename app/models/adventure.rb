class Adventure < ApplicationRecord
  belongs_to :user
  belongs_to :hunt
  belongs_to :current_clue, class_name: "Clue", optional: true

  enum :status, {
    in_progress: 1,
    completed: 2,
    abandoned: 3
  }

  validates :status, presence: true
  validate :only_one_in_progress_per_user_per_hunt, on: :create

  # Initialize current_clue_id with the first available clue from the hunt (in creation order)
  before_validation :set_initial_clue, on: :create, if: -> { current_clue_id.nil? && hunt.present? }

  # current_clue is provided by the belongs_to association

  # Ensure current_clue_id is set for in_progress adventures.
  # Returns true if a clue was assigned, false if no clues available.
  def ensure_current_clue!
    return true if current_clue_id.present?
    return false unless in_progress? && hunt

    set_initial_clue
    save! if current_clue_id_changed?
    current_clue_id.present?
  end

  # Check if all clues are solved
  def all_clues_solved?
    return false unless hunt

    total_clues = hunt.clues.size
    solved_count = solved_clue_ids.count

    # Adventure is complete when all clues are solved
    total_clues > 0 && solved_count >= total_clues
  end

  # Mark current clue as solved and move to next clue
  def solve_current_clue!
    clue = current_clue
    return false unless clue

    # Add to solved clues
    self.solved_clue_ids << clue.id unless solved_clue_ids.include?(clue.id)

    # Find next unsolved clue
    next_clue = find_next_clue

    if next_clue
      self.current_clue_id = next_clue.id
    else
      # No more clues, mark as completed
      self.current_clue_id = nil
      self.status = :completed
    end

    save!
    true
  end

  private

  def only_one_in_progress_per_user_per_hunt
    if in_progress? && user && hunt
      existing = user.adventures.where(hunt: hunt, status: :in_progress).where.not(id: id)
      if existing.exists?
        errors.add(:base, "You already have an active adventure for this hunt. Please complete it first.")
      end
    end
  end

  def set_initial_clue
    self.current_clue_id = next_available_clue_id
  end

  def find_next_clue
    clue_id = next_available_clue_id
    clue_id ? Clue.find_by(id: clue_id) : nil
  end

  def next_available_clue_id
    return nil unless hunt

    available = hunt.clues.order(:id).pluck(:id) - solved_clue_ids
    available.first
  end
end
