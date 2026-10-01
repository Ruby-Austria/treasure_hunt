class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :user

  validates :user_id, uniqueness: { message: "is already in a team" }
end
