require "test_helper"

class TargetQueueTest < ActiveSupport::TestCase
  # Validations

  test "valid target queue" do
    tq = TargetQueue.new(city: "Sarajevo", country: "BA", hunts_to_generate: 3)
    assert tq.valid?
  end

  test "city is required" do
    tq = TargetQueue.new(city: nil, country: "BA", hunts_to_generate: 1)
    assert_not tq.valid?
    assert_includes tq.errors[:city], "can't be blank"
  end

  test "country is required" do
    tq = TargetQueue.new(city: "Sarajevo", country: nil, hunts_to_generate: 1)
    assert_not tq.valid?
    assert_includes tq.errors[:country], "can't be blank"
  end

  test "hunts_to_generate must be positive" do
    tq = TargetQueue.new(city: "Sarajevo", country: "BA", hunts_to_generate: 0)
    assert_not tq.valid?

    tq.hunts_to_generate = -1
    assert_not tq.valid?

    tq.hunts_to_generate = 1
    assert tq.valid?
  end

  # Scopes

  test "pending scope returns unprocessed targets" do
    processed = TargetQueue.create!(city: "Done", country: "XX", hunts_to_generate: 1, processed: true)
    pending = TargetQueue.create!(city: "Pending", country: "XX", hunts_to_generate: 1, processed: false)

    result = TargetQueue.pending
    assert_includes result, pending
    assert_not_includes result, processed
  end

  test "incomplete scope returns targets with remaining hunts" do
    complete = TargetQueue.create!(city: "Complete", country: "XX", hunts_to_generate: 2, hunts_generated_count: 2)
    incomplete = TargetQueue.create!(city: "Incomplete", country: "XX", hunts_to_generate: 3, hunts_generated_count: 1)

    result = TargetQueue.incomplete
    assert_includes result, incomplete
    assert_not_includes result, complete
  end

  test "by_priority orders by priority desc then created_at asc" do
    old_low = TargetQueue.create!(city: "OldLow", country: "XX", hunts_to_generate: 1, priority: 1, created_at: 2.days.ago)
    new_high = TargetQueue.create!(city: "NewHigh", country: "XX", hunts_to_generate: 1, priority: 10, created_at: 1.day.ago)
    old_high = TargetQueue.create!(city: "OldHigh", country: "XX", hunts_to_generate: 1, priority: 10, created_at: 2.days.ago)

    result = TargetQueue.by_priority.where(id: [ old_low.id, new_high.id, old_high.id ])
    assert_equal [ old_high, new_high, old_low ].map(&:id), result.map(&:id)
  end

  # Instance methods

  test "incomplete? returns true when hunts remaining" do
    tq = TargetQueue.new(hunts_to_generate: 3, hunts_generated_count: 1)
    assert tq.incomplete?
  end

  test "incomplete? returns false when all hunts generated" do
    tq = TargetQueue.new(hunts_to_generate: 3, hunts_generated_count: 3)
    assert_not tq.incomplete?
  end

  test "incomplete? returns false when over-generated" do
    tq = TargetQueue.new(hunts_to_generate: 2, hunts_generated_count: 5)
    assert_not tq.incomplete?
  end

  test "mark_processed! sets processed and timestamp" do
    tq = TargetQueue.create!(city: "Test", country: "XX", hunts_to_generate: 1)
    assert_not tq.processed?

    tq.mark_processed!
    tq.reload

    assert tq.processed?
    assert_not_nil tq.last_generated_at
  end

  test "increment_generated! increments count and sets timestamp" do
    tq = TargetQueue.create!(city: "Test", country: "XX", hunts_to_generate: 3, hunts_generated_count: 0)

    tq.increment_generated!
    tq.reload

    assert_equal 1, tq.hunts_generated_count
    assert_not_nil tq.last_generated_at
    assert_not tq.processed?, "should not be processed when incomplete"
  end

  test "increment_generated! auto-marks processed when complete" do
    tq = TargetQueue.create!(city: "Test", country: "XX", hunts_to_generate: 1, hunts_generated_count: 0)

    tq.increment_generated!
    tq.reload

    assert_equal 1, tq.hunts_generated_count
    assert tq.processed?, "should auto-process when all hunts generated"
  end

  # Class methods

  test "next_target returns highest priority pending incomplete target" do
    low = TargetQueue.create!(city: "Low", country: "XX", hunts_to_generate: 2, hunts_generated_count: 0, priority: 1, processed: false)
    high = TargetQueue.create!(city: "High", country: "XX", hunts_to_generate: 2, hunts_generated_count: 0, priority: 10, processed: false)
    TargetQueue.create!(city: "Processed", country: "XX", hunts_to_generate: 2, hunts_generated_count: 0, priority: 100, processed: true)

    assert_equal high, TargetQueue.next_target
  end

  test "next_target returns nil when no pending incomplete targets" do
    TargetQueue.where(processed: false).update_all(processed: true)
    assert_nil TargetQueue.next_target
  end
end
