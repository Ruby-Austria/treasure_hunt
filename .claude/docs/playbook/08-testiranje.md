# Segment 8: Testiranje

## TDD Disciplina — RED-GREEN-REFACTOR

**Non-negotiable workflow:**

1. **RED**: Napiši minimalan test koji MORA failati
2. **VERIFIKUJ FAIL**: Pokreni test i POTVRDI da faila sa očekivanom porukom
3. **GREEN**: Napiši najjednostavniju implementaciju koja prolazi test
4. **REFACTOR**: Očisti kod, pokreni test ponovo da provjeriš da prolazi

> "Ako nisi gledao test da faila, ne znaš da li testira pravu stvar."

**Primjer workflow-a:**

```bash
# 1. Napiši test
# 2. Pokreni ga — MORA failati
bin/rails test test/models/hunt_test.rb
# Expected: 1 failure
# => "Expected Hunt to validate presence of :name"

# 3. Implementiraj
# validates :name, presence: true

# 4. Pokreni ponovo — MORA proći
bin/rails test test/models/hunt_test.rb
# Expected: 0 failures

# 5. Refactor ako treba, pokreni ponovo
```

## Struktura testova

```
test/
├── fixtures/
│   ├── users.yml
│   ├── hunts.yml
│   ├── locations.yml
│   └── clues.yml
├── models/
│   └── adventure_test.rb
├── services/
│   ├── claim_clue_service_test.rb
│   └── location_check_service_test.rb
├── controllers/            # Request testovi
│   ├── hunts_controller_test.rb
│   └── admin/
├── integration/            # Full-stack testovi
│   └── adventure_flow_test.rb
└── test_helper.rb
```

## Fixture pattern

```yaml
# test/fixtures/users.yml
regular_user:
  email: user@example.com
  password_digest: <%= BCrypt::Password.create('password') %>
  admin: false

admin_user:
  email: admin@example.com
  password_digest: <%= BCrypt::Password.create('password') %>
  admin: true
```

## Model test pattern

```ruby
class MyModelTest < ActiveSupport::TestCase
  def setup
    @user = users(:regular_user)
    @hunt = hunts(:two)
    @hunt.update!(status: :approved)

    @location = locations(:one)
    @clue = Clue.find_or_create_by!(hunt: @hunt, location: @location, difficulty: :easy)

    @valid_attributes = {
      user: @user,
      hunt: @hunt,
      status: :in_progress
    }
  end

  # Validacije
  test "should be valid with valid attributes" do
    model = MyModel.new(@valid_attributes)
    assert model.valid?
  end

  test "should require user" do
    model = MyModel.new(@valid_attributes.except(:user))
    assert_not model.valid?
    assert_includes model.errors[:user], "must exist"
  end

  # Asocijacije
  test "should belong to user" do
    model = MyModel.create!(@valid_attributes)
    assert_equal @user, model.user
  end

  # Enum
  test "should have status enum" do
    assert_equal 1, MyModel.statuses[:in_progress]
  end
end
```

## Service test pattern

```ruby
class MyServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:regular_user)
    @hunt = hunts(:two)
    @hunt.update!(status: :approved)

    @adventure = Adventure.create!(user: @user, hunt: @hunt, status: :in_progress)

    @valid_token = SecureRandom.hex(32)
    @adventure.update!(
      current_clue_claim_token: @valid_token,
      current_clue_claim_token_expires_at: 2.minutes.from_now
    )
  end

  test "should succeed with valid params" do
    service = MyService.new(adventure: @adventure, token: @valid_token).call

    assert service.success?
    assert_nil service.error
    assert_includes @adventure.reload.solved_clue_ids, @clue.id
  end

  test "should fail with invalid params" do
    service = MyService.new(adventure: @adventure, token: nil).call

    assert_not service.success?
    assert_equal "Token is required", service.error
  end
end
```

## Controller/Request test pattern

```ruby
class HuntsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:regular_user)
    @hunt = hunts(:two)
    @hunt.update!(status: :approved)
  end

  test "should redirect to login when not authenticated" do
    get hunt_path(@hunt)
    assert_redirected_to login_path
  end

  test "should show hunt when authenticated" do
    post login_path, params: { email: @user.email, password: "password" }
    get hunt_path(@hunt)
    assert_response :success
    assert_select "h1", @hunt.name
  end

  test "should return JSON for API endpoints" do
    post login_path, params: { email: @user.email, password: "password" }
    post check_location_adventure_path(@adventure),
         params: { latitude: 40.7829, longitude: -73.9654 },
         as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("distance")
  end
end
```

## System test pattern (Capybara)

```ruby
class AdventureFlowTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "player can start adventure and check location" do
    visit login_path
    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "password"
    click_on "Log In"

    click_on "City Adventure Hunt"
    click_on "Start Adventure"

    assert_text "Current Clue"
    assert_selector "[data-controller='adventure']"
  end
end
```

## Pokretanje testova

```bash
bin/rails test                           # Svi testovi
bin/rails test test/models/              # Samo model testovi
bin/rails test test/services/            # Samo service testovi
bin/rails test test/controllers/         # Samo controller testovi
bin/rails test test/models/hunt_test.rb  # Specifičan fajl
bin/rails test test/models/hunt_test.rb:42  # Specifičan test (linija)
```

## Code Coverage — SimpleCov + Undercover

### SimpleCov konfiguracija

SimpleCov se konfiguriše na vrhu `test/test_helper.rb` — MORA biti prije `require "rails/test_help"`:

```ruby
require "simplecov"
require "simplecov-lcov"

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
])

SimpleCov.start "rails" do
  enable_coverage :branch
  minimum_coverage 0       # Postavi na realan threshold (npr. 70) kad suite bude stabilan
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/vendor/"
end
```

Generiše izvještaje u `coverage/` direktoriju (HTML + LCOV format).

### Undercover — diff-aware coverage gate

Undercover analizira git diff i traži linije koje su promijenjene ali nemaju test coverage:

```bash
# Lokalno: provjeri nepokrivene promjene vs main
bundle exec undercover --compare origin/main

# CI: automatski na svakom PR-u (vidi .github/workflows/ci.yml)
```

**Ključno:** undercover neće proći ako novi/promijenjeni kod nema testove. Ovo forsira TDD disciplinu na nivou CI/CD pipeline-a.

### WebMock — HTTP stubbing

WebMock blokira sve externe HTTP pozive u testovima. Konfigurisano u `test_helper.rb`:

```ruby
require "webmock/minitest"
WebMock.disable_net_connect!(allow_localhost: true)
```

## Security testiranje — Brakeman

```bash
bundle exec brakeman              # Full scan sa izvještajem
bundle exec brakeman -q           # Quiet mode — samo warnings
bundle exec brakeman --no-pager   # Bez pager-a (za CI)
bundle exec brakeman -w2          # Samo high-confidence warnings
```

**Pokreni Brakeman:**
- Prije svakog push-a na main
- Nakon dodavanja novog controller-a ili route-a
- Nakon promjene auth logike

Brakeman provjerava: SQL injection, XSS, CSRF, mass assignment, command injection, file access, redirect vulnerabilities.

## Pravila za testove

1. **TDD RED-GREEN-REFACTOR** — nikad ne preskoči verify-fail korak
2. **Setup** priprema kompletno stanje — fixture-i + explicit state
3. **Jedan koncept po testu** — ali dozvoljena su related assertions
4. **Test name opisuje ponašanje**: `"should fail when token expired"`
5. **Reload model** nakon service poziva: `@model.reload`
6. **find_or_create_by!** za setup podatke koji možda postoje u fixture-ima
7. **Testovi za success i failure** path za svaki service
8. **Real kod umjesto mock-ova** kad god je moguće
9. **assert_response** za HTTP status, **assert_select** za HTML content
10. **as: :json** za testiranje JSON API endpoint-a

---

## Povezani segmenti

- [01-modeli](01-modeli.md) - Model pattern-i koje testovi validiraju
- [02-servisi](02-servisi.md) - Service pattern-i koje testovi pokrivaju
- [05-baza](05-baza.md) - Fixture podaci moraju odgovarati DB constraintima
- [10-code-quality](10-code-quality.md) - Brakeman, Rubocop, code quality standardi
