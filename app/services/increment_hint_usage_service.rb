class IncrementHintUsageService
  COOLDOWN_MINUTES = 30

  attr_reader :adventure, :error, :hint, :hints_used, :revealed_hints,
              :next_hint_available_at, :cooldown_remaining, :cooldown_remaining_minutes

  def initialize(adventure:)
    @adventure = adventure
    @error = nil
    @hint = nil
  end

  def call
    @adventure.reload
    @adventure.ensure_current_clue!

    current_clue = @adventure.current_clue
    unless current_clue
      @error = "No current clue available"
      return self
    end

    all_hints = current_clue.hints || []
    if all_hints.empty?
      @error = "No hints available for this clue"
      return self
    end

    unrevealed = all_hints - (@adventure.revealed_hints || [])

    if unrevealed.empty?
      @hints_used = @adventure.hints_used
      @revealed_hints = @adventure.revealed_hints
      return self
    end

    return self if on_cooldown?

    reveal_hint(unrevealed.sample)
    self
  end

  def success? = @error.nil?

  private

  def on_cooldown?
    return false unless @adventure.last_hint_revealed_at.present?

    elapsed = Time.current - @adventure.last_hint_revealed_at
    cooldown = COOLDOWN_MINUTES.minutes.to_i
    return false if elapsed >= cooldown

    remaining = cooldown - elapsed.to_i
    @error = "Please wait before revealing another hint"
    @cooldown_remaining = remaining
    @cooldown_remaining_minutes = (remaining / 60.0).round(2)
    @next_hint_available_at = @adventure.last_hint_revealed_at + cooldown
    true
  end

  def reveal_hint(hint_text)
    revealed = (@adventure.revealed_hints || []) + [ hint_text ]

    @adventure.update!(
      revealed_hints: revealed,
      hints_used: @adventure.hints_used + 1,
      last_hint_revealed_at: Time.current
    )

    @hint = hint_text
    @hints_used = @adventure.hints_used
    @revealed_hints = @adventure.revealed_hints
    @next_hint_available_at = Time.current + COOLDOWN_MINUTES.minutes
  end
end
