# Segment 1: Modeli

## Redoslijed u model fajlu

```ruby
class MyModel < ApplicationRecord
  # 1. Acts-as plugini
  acts_as_taggable_on :tags

  # 2. Enum definicije (PRIJE asocijacija)
  enum :status, { draft: 1, approved: 2, archived: 3 }
  enum :verification_state, { ai_generated: 0, auto_verified: 1 }, default: :ai_generated

  # 3. Asocijacije
  belongs_to :parent
  belongs_to :optional_parent, class_name: "OtherModel", optional: true
  has_many :children, dependent: :destroy
  has_many :grandchildren, through: :children

  # 4. Validacije
  validates :name, presence: true
  validates :lat, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :score, numericality: { in: 0..1 }, allow_nil: true
  validates :parent_id, uniqueness: { scope: :child_id, message: "already exists" }

  # 5. Callback-ovi
  before_validation :set_defaults, on: :create, if: -> { some_condition? }

  # 6. Delegacije
  delegate :some_method, to: :parent, prefix: false

  # 7. Scope-ovi
  scope :pending, -> { where(processed: false) }
  scope :by_priority, -> { order(priority: :desc, created_at: :asc) }

  # 8. Instance metode
  def my_business_logic
    # ...
  end
end
```

## Enum konvencije

- Koristi integer-backed enum-e: `{ draft: 1, approved: 2 }`
- Za default vrijednost koristi `default:` opciju (bez underscore-a, Rails 8.1.1+)
- Definiši enum PRIJE asocijacija da izbjegneš konflikte metoda

## Validacije

- GPS koordinate: `numericality` sa range-om (-90..90 za lat, -180..180 za lng)
- Decimal score-ovi (0-1): `numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true`
- Unique kombinacije: `uniqueness: { scope: :other_field }`

## Asocijacije

- `optional: true` za belongs_to koje smije biti nil
- `class_name:` za custom asocijacije: `belongs_to :current_clue, class_name: "Clue", optional: true`
- `dependent: :destroy` na has_many

## Community Learning pattern

Modeli koji se poboljšavaju korisničkim podacima koriste weighted average:

```ruby
def update_from_player_claim(player_lat, player_lng)
  new_count = usage_count + 1
  new_avg_lat = (avg_player_lat * 0.8) + (player_lat * 0.2)
  new_avg_lng = (avg_player_lng * 0.8) + (player_lng * 0.2)

  update!(usage_count: new_count, avg_player_lat: new_avg_lat, avg_player_lng: new_avg_lng)

  # Auto-verifikacija nakon dovoljno claim-ova
  auto_verified! if usage_count >= 10 && ai_generated?
end
```

## Sandi Metz pravila za modele

- **≤ 100 linija** po klasi — ako model raste, izvuci logiku u Concern ili Service
- **≤ 5 linija** po metodi — kompleksna logika ide u Service objekt
- **≤ 4 parametra** — koristi keyword arguments ili options hash
- Detalji u [10-code-quality](10-code-quality.md)

## Ruby idiomi u modelima

```ruby
# Endless methods za predikate
def solved? = solved_clue_ids.include?(clue_id)
def free? = price.zero?

# filter_map umjesto select + map
def active_locations = locations.filter_map { |l| l if l.verified? }

# Guard clauses umjesto nested if-ova
def claim!
  return false unless in_progress?
  return false if all_clues_solved?
  update!(claimed_at: Time.current)
end
```

---

## Povezani segmenti

- [02-servisi](02-servisi.md) - Servisi koji koriste modele (ClaimClueService, LocationCheckService)
- [05-baza](05-baza.md) - Migracije i indeksi za model polja
- [08-testiranje](08-testiranje.md) - Model test pattern-i i fixture-i
- [09-rute-auth](09-rute-auth.md) - User model i auth helper-i
- [10-code-quality](10-code-quality.md) - Sandi Metz pravila, Ruby idiomi
