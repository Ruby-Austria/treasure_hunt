class Admin::DashboardController < Admin::BaseController
  def index
    @stats = {
      users_total: User.count,
      users_admin: User.where(admin: true).count,
      locations_total: Location.count,
      locations_tags: ActsAsTaggableOn::Tag.joins(:taggings).where(taggings: { taggable_type: "Location" }).distinct.count,
      hunts_total: Hunt.count,
      hunts_draft: Hunt.draft.count,
      hunts_approved: Hunt.approved.count,
      hunts_archived: Hunt.archived.count,
      hunts_tags: ActsAsTaggableOn::Tag.joins(:taggings).where(taggings: { taggable_type: "Hunt" }).distinct.count,
      clues_total: Clue.count,
      adventures_total: Adventure.count,
      adventures_in_progress: Adventure.in_progress.count,
      adventures_completed: Adventure.completed.count,
      users_flagged: User.where.not(flagged_at: nil).count
    }
    @flagged_users = User.where.not(flagged_at: nil).order(flagged_at: :desc)
  end
end
