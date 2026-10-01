class LeaderboardController < ApplicationController
  PER_PAGE = 5

  def index
    @hunts = Hunt.approved.where(id: Clue.select(:hunt_id)).includes(:clues).order(:name)
    all_rankings = build_rankings
    @rankings = {}
    @pagination = {}
    @current_user_rank = {}

    @hunts.each do |hunt|
      entries = all_rankings[hunt.id] || []
      page = (params["page_#{hunt.id}"] || 1).to_i
      page = 1 if page < 1
      total_pages = (entries.size.to_f / PER_PAGE).ceil
      page = total_pages if total_pages > 0 && page > total_pages

      page_entries = entries.slice((page - 1) * PER_PAGE, PER_PAGE) || []
      @rankings[hunt.id] = page_entries
      @pagination[hunt.id] = { page: page, total_pages: total_pages, total_entries: entries.size }

      if logged_in?
        user_entry = find_current_user_entry(entries)
        if user_entry && !page_entries.include?(user_entry[:entry])
          @current_user_rank[hunt.id] = user_entry
        end
      end
    end
  end

  private

  def find_current_user_entry(entries)
    entries.each_with_index do |entry, i|
      is_match = if current_user.team
        entry[:team] && entry[:name] == current_user.team.name
      else
        !entry[:team] && entry[:name] == current_user.display_name
      end

      return { entry: entry, rank: i } if is_match
    end
    nil
  end

  def build_rankings
    rankings = {}

    @hunts.each do |hunt|
      adventures = Adventure.where(hunt: hunt)
        .where(status: [ :in_progress, :completed ])
        .includes(user: :team)

      entries = {}

      adventures.find_each do |adventure|
        team = adventure.user.team
        key = team ? "team_#{team.id}" : "user_#{adventure.user_id}"

        if entries[key].nil? || adventure.solved_clue_ids.count > entries[key][:solved]
          entries[key] = {
            name: team ? team.name : adventure.user.display_name,
            team: team.present?,
            member_count: team&.members&.count || 1,
            solved: adventure.solved_clue_ids.count,
            total: hunt.clues.count,
            completed: adventure.completed?,
            last_solve_at: adventure.updated_at
          }
        end
      end

      rankings[hunt.id] = entries.values
        .sort_by { |e| [ -e[:solved], e[:last_solve_at] ] }
    end

    rankings
  end
end
