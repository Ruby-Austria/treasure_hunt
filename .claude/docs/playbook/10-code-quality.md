# Segment 10: Code Quality i Debugging

## Sandi Metz pravila

Heuristike za čist, održiv kod. Nisu apsolutna — ali svako kršenje zahtijeva dobar razlog.

| Pravilo | Limit | Zašto |
|---------|-------|-------|
| Klase | ≤ 100 linija | Single Responsibility — klasa radi jednu stvar |
| Metode | ≤ 5 linija | Jasnoća — metoda je čitljiva na prvi pogled |
| Parametri | ≤ 4 po metodi | Smanjuje coupling — previše parametara = skriveni objekt |
| Controller akcije | 1 instancirani objekt | Thin controller — logika u modelu/servisu |

### Primjena u TreasureHunt.io

```ruby
# DOBRO: Metoda od 5 linija, jasna odgovornost
def check_location
  validate_params!
  result = LocationCheckService.new(params).call
  render json: result
end

# LOŠE: Fat controller akcija, 20+ linija logike
def check_location
  lat = params[:latitude].to_f
  lng = params[:longitude].to_f
  # ... 15 linija kalkulacije ...
  render json: { distance: calculated_distance }
end
```

### Kada je OK prekršiti

- **Metode > 5 linija**: `setup` u testovima, kompleksni SQL query-ji
- **Klase > 100 linija**: Modeli sa mnogo validacija i asocijacija (ali razmisli o concerns)
- **> 4 parametra**: Keyword arguments sa defaults-ima (koristi Hash/options pattern)

---

## Ruby idiomi

### Error Handling

```ruby
# Weirich konvencija: fail za prvu iznimku, raise za re-raise
def process
  fail ArgumentError, "missing param" unless param.present?
rescue StandardError => e
  Rails.logger.error(e.message)
  raise  # Re-raise sa raise, ne fail
end

# Prefer result objects nad exceptions za očekivane failure-e
# (Već koristimo u Service pattern-u: success?/error)
```

### Modern Ruby (3.x+)

```ruby
# Pattern matching sa guards
case user
in { admin: true, email: /.*@treasurehunt\.io/ }
  grant_full_access
in { admin: false }
  grant_standard_access
end

# Endless methods (za jednostavne predikate)
def logged_in? = !!current_user
def admin? = logged_in? && current_user.admin?

# filter_map (umjesto select + map)
active_emails = users.filter_map { |u| u.email if u.active? }

# tally (umjesto group_by + count)
status_counts = hunts.map(&:status).tally
# => { "draft" => 5, "approved" => 3 }
```

### Memoization — nil/false caveat

```ruby
# OPASNO: ne radi ako rezultat može biti nil ili false
def users = @users ||= User.all.to_a

# SIGURNO: koristi defined? za nil/false-safe memoization
def feature_enabled?
  return @feature_enabled if defined?(@feature_enabled)
  @feature_enabled = expensive_check
end
```

### Custom Exception Hierarchies

```ruby
module TreasureHunt
  class Error < StandardError; end
  class LocationError < Error; end
  class ClaimError < Error; end
  class AIGenerationError < Error; end
end

# Rescue na bilo kojoj granularnosti:
rescue TreasureHunt::ClaimError        # specifičan
rescue TreasureHunt::Error             # sve app greške
# NIKAD: rescue Exception — hvata SignalException, NoMemoryError
```

### Performance idiomi

```ruby
# Frozen string literals (na vrhu fajla)
# frozen_string_literal: true

# each_with_object umjesto inject za hash building
result = items.each_with_object({}) do |item, hash|
  hash[item.id] = item.name
end

# String building sa << ili join (NE +=, koji je O(n²))
parts = []
parts << "Hello"
parts << name
message = parts.join(" ")

# Lazy enumerables za velike kolekcije
large_list.lazy.select(&:active?).first(10)

# Hash#fetch za obavezne ključeve (baca KeyError)
config.fetch(:api_key)              # raises KeyError if missing
config.fetch(:timeout, 30)          # sa default vrijednošću
config.fetch(:handler) { build }    # sa lazy default-om

# Literal array constructori
STATES = %w[draft approved archived]    # word array
FIELDS = %i[name email created_at]     # symbol array
```

### Naming konvencije

```ruby
# ? za predikate
def solved? = solved_clue_ids.include?(clue_id)

# ! za mutacije ili opasne operacije
def approve! = update!(status: :approved)

# _ prefix za namjerno nekorištene varijable
items.each_with_index { |_item, index| process(index) }
```

---

## Systematic Debugging — 4-fazni pristup

Kada naiđeš na bug, **nikad ne nagađaj**. Slijedi strukturiran proces:

### Faza 1: Reprodukcija

```bash
# Reproduciraj bug sa minimalnim koracima
bin/rails test test/models/adventure_test.rb:42
# Ili u browseru: prati tačne korake
```

- Zapiši tačne korake za reprodukciju
- Identificiraj: radi li nekad? Samo u specifičnim okolnostima?

### Faza 2: Izolacija

```ruby
# Suzuj scope — koji dio koda uzrokuje problem?

# Rails console za brzu provjeru
bin/rails console
> adventure = Adventure.last
> adventure.current_clue  # nil? stale?

# Logovi
Rails.logger.debug("DEBUG: adventure=#{adventure.inspect}, clue=#{adventure.current_clue_id}")

# Breakpoint (ako koristiš debugger)
binding.irb  # ili debugger
```

### Faza 3: Root Cause Analysis

Pitaj se:
1. **Šta se promijenilo?** (git log, git diff)
2. **Šta je drugačije?** (env, data, timing)
3. **Koji sloj je odgovoran?** (model, controller, view, JS, DB)

```bash
# Provjeri šta se promijenilo nedavno
git log --oneline -10
git diff HEAD~3..HEAD -- app/models/

# Provjeri DB state
bin/rails runner "pp Adventure.last.attributes"
```

### Faza 4: Fix i Verifikacija

```bash
# 1. Napiši test koji reproducira bug (RED)
# 2. Popravi bug (GREEN)
# 3. Pokreni sve testove da nisi slomio nešto drugo
bin/rails test
# 4. Pokreni Brakeman ako je security-related
bundle exec brakeman -q
```

---

## Static Analysis

### RuboCop

```bash
bundle exec rubocop                    # Full scan
bundle exec rubocop app/models/        # Samo modeli
bundle exec rubocop -a                 # Auto-fix safe violations
bundle exec rubocop --auto-gen-config  # Generiši .rubocop_todo.yml
```

### Brakeman (Security)

```bash
bundle exec brakeman -q --no-pager     # Quick security scan
```

**Pokreni nakon:**
- Novog controller-a ili route-a
- Promjene auth/session logike
- Dodavanja user input handling-a
- Prije push-a na main

### Undercover (Diff Coverage)

```bash
bundle exec undercover --compare origin/main  # Provjeri coverage novih/promijenjenih linija
```

Koristi SimpleCov LCOV izvještaj da identificira nepokrivene promjene. Automatski se pokreće u CI na svakom PR-u. Neće proći ako je novi kod bez testova.

### CI/CD integracija

```yaml
# .github/workflows/ci.yml
- name: Security scan
  run: bundle exec brakeman -q --no-pager --no-exit-on-warn

- name: Lint
  run: bundle exec rubocop --parallel

- name: Test
  run: bin/rails test

- name: Diff coverage
  if: github.event_name == 'pull_request'
  run: bundle exec undercover --compare origin/${{ github.base_ref }}
```

---

## Code Review Checklist

Prije push-a ili merge-a provjeri:

- [ ] **Testovi prolaze**: `bin/rails test`
- [ ] **Coverage za promjene**: `bundle exec undercover --compare origin/main`
- [ ] **Security scan čist**: `bundle exec brakeman -q`
- [ ] **Nema N+1 query-ja**: Provjeri `includes` na has_many asocijacijama
- [ ] **Ownership provjere**: Svaka user-facing akcija provjerava `@model.user == current_user`
- [ ] **HTTP status kodovi**: 422 za form errors, 303 za redirect, 401 za unauthorized
- [ ] **CSRF token**: Svi fetch pozivi šalju X-CSRF-Token header
- [ ] **Tailwind klase**: Nikad inline stilovi, koristi DESIGN.md
- [ ] **Sandi Metz**: Klase < 100 linija, metode < 5 linija

---

## Povezani segmenti

- [01-modeli](01-modeli.md) - Model organizacija po Sandi Metz pravilima
- [02-servisi](02-servisi.md) - Service objects za izdvajanje logike iz kontrolera
- [03-kontroleri](03-kontroleri.md) - Thin controller pattern
- [08-testiranje](08-testiranje.md) - TDD workflow i Brakeman integracija
