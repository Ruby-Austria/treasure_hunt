# frozen_string_literal: true

# Stats API Controller
# Provides real-time platform statistics for homepage counter
class StatsController < ApplicationController
  # GET /stats.json
  # Returns platform statistics with 5-minute caching
  # Public endpoint - no authentication required
  def index
    stats = Rails.cache.fetch("platform_stats", expires_in: 5.minutes) do
      calculate_stats
    end

    render json: stats
  rescue StandardError => e
    Rails.logger.error("Stats calculation error: #{e.class} - #{e.message}")
    render json: { error: "Stats temporarily unavailable" }, status: :service_unavailable
  end

  private

  def calculate_stats
    {
      hunts: Hunt.where(status: :approved).count,
      clues: Clue.joins(:hunt).where(hunts: { status: :approved }).count,
      locations: Location.count,
      cities: Location.distinct.pluck(:city).compact.size,
      # Optional stats for future use
      countries: Location.distinct.pluck(:country).compact.size,
      # adventures_completed: Adventure.where(status: :completed).count,
      generated_at: Time.current.iso8601
    }
  end
end
