# Segment 2: Servisi

## Gdje žive servisi

```
app/services/
├── claim_clue_service.rb         # Transakcijski service
├── distance_calculator.rb        # Shared haversine distance module
├── location_check_service.rb     # Kalkulacijski service
└── increment_hint_usage_service.rb # State mutation service
```

## Pattern 1: Transakcijski Service (ClaimClueService)

Za operacije koje mijenjaju stanje i mogu failati.

```ruby
class MyService
  attr_reader :result, :error

  def initialize(model:, param:)
    @model = model
    @param = param
    @error = nil
    @success = false
  end

  def call
    return self unless validate
    perform_action
    self  # Uvijek vraća self za chaining
  end

  def success?
    @success
  end

  private

  def validate
    unless @model.valid_state?
      @error = "Invalid state"
      return false
    end
    true
  end

  def perform_action
    @model.update!(...)
    @success = true
  rescue => e
    @error = e.message
  end
end
```

**Korištenje u kontroleru:**
```ruby
service = MyService.new(model: @model, param: value).call
if service.success?
  render json: { success: true }
else
  render json: { error: service.error }, status: :bad_request
end
```

## Pattern 2: Orchestrator

Za kompleksne multi-step workflow-e koji koordiniraju više servisa.

```ruby
class MyOrchestrator
  def initialize
    @service_a = ServiceA.new
    @service_b = ServiceB.new
  end

  def execute(params)
    # Korak 1: Prikupi resurse
    resources = @service_a.find(params)

    # Korak 2: Kreiraj glavni record
    record = Model.create!(...)

    # Korak 3: Generiši sadržaj za svaki resurs
    resources.each do |resource|
      content = @service_b.generate(resource)
      record.children.create!(content)
    end

    # Korak 4: Finaliziraj
    record.update!(status: :ready)
    record
  rescue => e
    Rails.logger.error("#{self.class.name} failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise
  end
end
```

## Pattern 3: Strategy Service (LocationScout)

Database-first pristup: provjeri lokalno prije API poziva.

```ruby
class MyScout
  def initialize
    @api_client = ExternalApiClient.new
  end

  def find(criteria, count: 6)
    # 1. Provjeri bazu prvo
    existing = Model.where(criteria)
    return existing.limit(count) if existing.count >= count

    # 2. Ako nema dovoljno, pozovi API
    api_results = @api_client.search(criteria)

    # 3. Persisti nove rezultate
    new_records = api_results.map { |r| Model.find_or_create_by!(external_id: r[:id]) { |m| m.assign_attributes(r) } }

    (existing + new_records).first(count)
  end
end
```

## Pattern 4: State Mutation Service (IncrementHintUsage)

Za operacije sa cooldown logikom i atomskim update-ima.

```ruby
class MyCooldownService
  attr_reader :error, :cooldown_remaining

  def initialize(model:)
    @model = model
    @error = nil
  end

  def call
    @model.reload  # Svjež state

    # Provjeri cooldown
    if @model.last_action_at.present?
      elapsed = Time.current - @model.last_action_at
      if elapsed < COOLDOWN_SECONDS
        @cooldown_remaining = COOLDOWN_SECONDS - elapsed.to_i
        @error = "Please wait"
        return self
      end
    end

    # Atomski update
    @model.update!(
      counter: @model.counter + 1,
      last_action_at: Time.current
    )

    self
  end

  def success?
    @error.nil?
  end
end
```

## Pravila za servise

1. **Uvijek vraćaj `self`** iz `call` metode za chaining
2. **`success?` metoda** za provjeru ishoda
3. **`attr_reader :error`** za pristup grešci
4. **`@model.reload`** prije mutacija da spriječiš stale state
5. **Rescue i loguj** u orchestrator-ima, ne u leaf servisima
6. **Fallback vrijednosti** za slučaj kada eksterni servis ne radi

---

## Povezani segmenti

- [01-modeli](01-modeli.md) - Modeli koje servisi koriste i mutiraju
- [03-kontroleri](03-kontroleri.md) - Kako kontroleri pozivaju servise (`Service.new(...).call`)
- [08-testiranje](08-testiranje.md) - Service test pattern-i
- [10-code-quality](10-code-quality.md) - Sandi Metz pravila za veličinu klasa i metoda
