class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }

  # Associations
  has_many :adventures, dependent: :destroy
  has_many :hunts, through: :adventures
  has_one :team_membership, dependent: :destroy
  has_one :team, through: :team_membership

  def flagged? = flagged_at.present?

  def display_name
    if first_name.present?
      [ first_name, last_name ].compact_blank.join(" ")
    else
      email.split("@").first
    end
  end

  def team_members
    return User.none unless team
    team.members.where.not(id: id)
  end
end
