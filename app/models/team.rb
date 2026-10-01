class Team < ApplicationRecord
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships, source: :user

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :invite_code, presence: true, uniqueness: true

  before_validation :generate_invite_code, on: :create

  def regenerate_invite_code!
    update!(invite_code: self.class.generate_code)
  end

  def has_completed_adventures?
    members.joins(:adventures).where(adventures: { status: :completed }).exists?
  end

  def self.generate_code
    SecureRandom.alphanumeric(6).upcase
  end

  private

  def generate_invite_code
    self.invite_code ||= self.class.generate_code
  end
end
