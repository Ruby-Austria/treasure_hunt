# Wiki Activity Log

Hronološki, append-only zapis svih aktivnosti na knowledge base-u.

Format: `## [YYYY-MM-DD] operacija | naslov`

## [2026-04-13] improvement-loop | Playthrough report findings

### Kategorija: bug fixes + accessibility (no PRD needed) + PRD draft for UX

### Source: 10-persona browser playthrough report (`.claude/personas/playthrough-report.md`)

### Bug fixes (bez PRD)
- **"1 members" grammar**: Fixed pluralization in `adventures/show.html.erb` using `pluralize()`
- **Misleading text**: Changed "Real-time progress" to "Progress" on leaderboard (no WebSocket)
- **Temperature mapping**: Fixed cold level mapping from yellow ("warning") to blue ("cold") in `adventure_controller.js`
- **Cold style missing**: Added `cold: "bg-blue-50 border-blue-200 text-blue-800"` style
- **0-clue hunts visible**: Filtered hunts with no clues from dashboard and leaderboard using `where(id: Clue.select(:hunt_id))` subquery (avoids PG json DISTINCT issue)
- **Watermark a11y**: Added `aria-hidden="true"` to treasure reveal watermark

### Accessibility fixes (bez PRD)
- **Progress bar ARIA**: Added `role="progressbar"` with `aria-valuenow/min/max` and `aria-label` to all 6 progress bars across 4 views (adventures, dashboard, teams, leaderboard)
- **Toast announcements**: Added `role="status"` and `aria-live="polite"` to toast container in application layout
- **Color contrast**: Fixed `text-gray-400` → `text-gray-600` on abandon button, `text-gray-500` on leaderboard member counts and "View Details" link

### PRD-0010: Playthrough UX Improvements — Done

**FR-1: Temperature feedback** — Improved temperature messages to be more descriptive with emoji indicators (🔥🟠🟡🔵). Mapped "closer" level to yellow/warning style for proper gradient (blue→yellow→orange→green). Backend already sent temperature to all users — just improved messages.

**FR-2: Abandon button relocation** — Moved from hidden position below progress bar to header row (right-aligned next to "Back to Hunt"). Now visible without scrolling, 44px touch target, hover state with ruby-50 background.

**FR-3: Treasure availability badge** — Added gold "Treasure Available!" badge (`bg-yellow-100 text-yellow-800`) on dashboard hunt cards. Shows when: user completed hunt + hunt has treasure + treasure not yet claimed. Coexists with "Completed" badge. Disappears when treasure is claimed.

**FR-4: Touch target compliance** — Added `min-h-[44px]` to all nav bar links/buttons (Leaderboard, Team, Solo, Admin, Logout, Log In), leaderboard pagination buttons (also bumped to `text-sm px-4 py-2`), Leave Team button, and Abandon button. All interactive elements now meet WCAG 2.5.5 AAA 44px minimum.

### Testovi
- Prije: 473 tests, 1305 assertions
- Poslije: 473 tests, 1324 assertions, 0 failures, 0 errors
- Updated: leaderboard_controller_test (added clue to fixture for 0-clue filter)

### Validacija
- Rubocop: 2 pre-existing offenses (not from this session)
- Brakeman: 0 warnings
- All 473 tests green

---

## [2026-04-13] improvement-loop | PRD-0002 RubyConf.at Edition

### Kategorija: full (UX + auth + branding + admin)

### PRD: PRD-0002 — RubyConf.at Edition — Platform Narrowing → Done

### Promjene

**Z1: Auth** — Removed signup route/controller/views. Login redirects to root. Added password reset flow using Rails built-in `generates_token_for`. PasswordResetsController, PasswordResetMailer, views.

**Z2: Payment UI** — Removed Stripe checkout UI from hunt show page. Removed payment gate from AdventuresController#create. All hunts free.

**Z3: Branding** — Custom Tailwind theme with RubyConf.at colors (ruby-50..ruby-950, accent green). Downloaded logo SVG. Updated layout with ruby-900 nav, warm-50 background.

**Z4+Z6: Landing + Nav** — New conference-branded landing page with hero section, 4 hunt cards, active adventures. Merged home into landing (PagesController). Minimal nav: logo, admin, logout. Removed hunts#index, stats counter, "How It Works", featured hunts.

**Z5: Gameplay UI** — Mobile-first redesign of hunt show, adventure show. Progress bars, cleaner cards, ruby-themed colors throughout.

**Z7: Admin Attendees** — Admin::AttendeesController with single + bulk registration. Auto-generated passwords. Bulk import via textarea/CSV. Results view with copy-able passwords. Admin sidebar updated.

### Testovi
- Prije: 429 tests, 1214 assertions
- Poslije: 434 tests, 1220 assertions, 0 failures
- Novi testovi: password_resets_controller_test, admin/attendees_controller_test, user model password reset tests
- Ažurirani: home_controller_test, pages_controller_test, hunts_controller_test, users_controller_test, adventures_controller_test, platform_smoke_test

### Validacija
- Rubocop: 0 offenses
- Brakeman: 0 warnings
- All 434 tests green

Parseable: `grep "^## \[" .claude/docs/log.md | tail -10`

---

## [2026-04-07] init | Knowledge base kreiran

- Kreirana tri sloja dokumentacije: Playbook, ADR, PRD
- Playbook: 9 segmenata (modeli, servisi, kontroleri, views, baza, AI, API, testovi, rute)
- ADR-0001: Spec-Driven Development usvojen
- Slash komande: /adr, /prd, /implement, /playbook
- Stranice kreirane: 15
- Stranice ažurirane: 0

## [2026-04-07] ingest | Karpathy LLM Wiki pattern

- Izvor: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- Primijenjeni koncepti: unified index, activity log, ingest/lint operacije, cross-referencing, query-as-artifact
- Stranice kreirane: index.md, log.md
- Stranice ažurirane: svi playbook segmenti (cross-reference), CLAUDE.md, AGENT.md
- Komande dodane: /ingest, /lint

## [2026-04-07] implement | PRD-0001 UI Redesign

- PRD-0001: UI Redesign — Primjena DESIGN.md sistema
- Svih 20 template-a prerađeno na Tailwind CSS (FR-1 do FR-9)
- Zero inline stilova na cijeloj platformi
- Validirano kroz Chrome MCP — sve stranice renderuju korektno
- PRD status: Done

## [2026-04-07] ingest | superpowers-ruby pattern-i

- Izvor: https://github.com/lucianghinda/superpowers-ruby
- Primijenjeni koncepti:
  - **Hotwire suite**: Turbo Drive/Frames/Streams pattern-i, Stimulus lifecycle/targets/values/outlets/actions, UX feedback, debounce, optimistic UI
  - **TDD disciplina**: RED-GREEN-REFACTOR sa obaveznim verify-fail korakom
  - **Sandi Metz pravila**: 100-line classes, 5-line methods, 4 params max
  - **37signals konvencije**: thin controllers, Turbo HTTP statusi (422/303)
  - **Systematic debugging**: 4-fazni pristup (reprodukcija → izolacija → root cause → fix)
  - **Ruby 3.x idiomi**: pattern matching, endless methods, filter_map, tally, frozen strings
  - **Security**: Brakeman scan integracija, code review checklist
- Stranice kreirane: 10-code-quality.md (novi segment)
- Stranice ažurirane: 04-views-stimulus.md (major rewrite), 08-testiranje.md (TDD + Brakeman), 03-kontroleri.md (Turbo statusi + 37signals), 01-modeli.md (Ruby idiomi + Sandi Metz), INDEX.md, index.md

## [2026-04-07] ingest | Testing infrastructure & best practices

- **Gems dodani**: simplecov, simplecov-lcov, undercover, webmock, minitest (~> 5.25)
- **Konfiguracija**: SimpleCov sa branch coverage + LCOV formatter u test_helper.rb
- **WebMock**: Blokira sve eksterne HTTP pozive u testovima, dozvoljava localhost
- **Undercover**: Diff-aware coverage gate u CI — blokira PR-ove sa nepokrivenim kodom
- **CI pipeline**: Dodan undercover step na PR-ove, cmake za rugged, fetch-depth: 0 za git diff
- **Fixture bugovi popravljeni**: target_queues duplicate key, hunts/locations FK violation (tags → tag_list)
- **Minitest 6.0 pin**: Pinovan na 5.x jer Minitest 6 ima breaking API promjene za Rails 8.1
- **Nokogiri/PG ABI fix**: force_ruby_platform za source compilation na Ruby 3.4.0dev
- **Dockerfile**: Ruby version ažuriran sa 3.3.5 na 3.4.0
- **Procfile.dev**: Dodan Solid Queue worker process
- **Stranice ažurirane**: 08-testiranje.md (SimpleCov, undercover, WebMock), 10-code-quality.md (undercover, CI pipeline)

## [2026-04-07] improvement-loop | Autonomous product improvement sprint

Comprehensive improvement session covering security, testing, performance, and UX:

### Security
- **IDOR fix**: Adventures scoped to `current_user.adventures` preventing cross-user access
- **XSS fix**: Removed `raw()` from JSON data attributes in adventures view
- **Rate limiting**: Added Rails 8 `rate_limit` to login (10/3min) and signup (5/5min)
- **Gem updates**: Rails 8.1.1→8.1.3, Brakeman 7.1.2→8.0.4, fixed 9 gem CVEs
- **Session hardening**: `reset_session` for logout, `find_by` for deleted user resilience
- **JSON auth**: `require_login` now returns JSON 401 for API requests

### Testing (301→349 tests, +48)
- 40 new service tests: AI::GeminiClient, AI::RiddleGenerator, AI::StoryBridgeGenerator, GooglePlacesService, HuntFactory::LocationScout, HuntFactory::Orchestrator
- 8 new admin dashboard controller tests
- Fixed Zeitwerk inflection for AI namespace (`ai/` → `AI::`)

### Performance
- N+1 queries eliminated across 8 files (controllers + views)
- `.count` → `.size` for all eager-loaded collections
- Eager loading added to admin hunt show, hunt show, home, adventures

### UX
- Featured hunts on landing page (replaces static placeholder)
- Active adventures section on home page with progress indicators
- Proper error handling for all JSON API endpoints (claim, force_claim, hint)
- Stats endpoint returns 503 on failure instead of crashing

### Cleanup
- Removed unused `hello_controller.js` scaffold
- Moved view-level queries to controllers (dashboard, adventures)
- Rubocop array bracket spacing fixes across test files
- CI fully green: lint, scan_ruby, scan_js, system-test, test all passing

## [2026-04-07] improvement-loop | Continued product improvement sprint (session 2)

### Testing (349→403 tests, +54)
- User model: 17 tests (validations, auth, associations, admin, case-insensitive email)
- TargetQueue model: 14 tests (validations, scopes, instance methods, class methods)
- Location community learning: 9 tests (update_from_player_claim, confidence, auto-verify, within_radius?)
- Adventure ensure_current_clue!: 4 tests (edge cases for core gameplay method)
- DistanceCalculator: 6 tests (zero, symmetry, transatlantic, equator, antimeridian)
- Pages controller: 2 additional tests (redirect, featured hunts)

### Refactoring
- **DistanceCalculator module**: Extracted duplicate haversine from LocationCheckService and HuntFactory::Orchestrator into shared `app/services/distance_calculator.rb`
- **Location#within_radius? fix**: Method was broken (calling nonexistent service API). Replaced with DistanceCalculator

### Accessibility & Responsiveness
- Added `lang="en"` to both HTML layouts (WCAG requirement)
- Application nav: Hide email and Hunts link on mobile to prevent overflow
- Admin layout: Added mobile top bar navigation (desktop sidebar was invisible/overlapping on small screens)

### Performance
- Eager load tags in admin location show (`Location.includes(:tags)`)
- Eager load location tags in admin clue show (`Clue.includes(location: :tags)`)

## [2026-04-07] improvement-loop | Session 3 — Security, Turbo, /improve workflow

### Kategorija: full (from Chrome MCP QA test report)

### Process
- Created `/improve` skill — enforces spec gate (PRD/ADR) before implementation
- Added to CLAUDE.md command table and autonomous work rules

### Security (bez PRD)
- **Session fixation**: Added `reset_session` before login in SessionsController
- **Race condition**: Added `with_lock` in ClaimClueService for concurrent claim protection
- **Password validation**: Added `validates :password, length: { minimum: 6 }` server-side
- **Admin adventure access**: Fixed `set_adventure` to allow admin to view any adventure

### Bug fixes (bez PRD)
- **0-clue hunt**: Prevented adventure creation for hunts with no clues (controller guard + view disable)
- **Hint counter**: Added Stimulus target `hintsUsedBadge` — updates live after hint reveal
- **Login error**: Removed `local: true` from login/signup forms for Turbo Drive compatibility
- **Logout reliability**: Added `status: :see_other` (303) to all auth redirects (login, logout, signup)
- **Pluralization**: Fixed "1 clues" → `pluralize(hunt.clues.size, 'clue')` on landing page
- **confirm() popup**: Replaced browser `confirm()` with inline modal for force claim (Chrome MCP compatible)

### Performance (bez PRD)
- **Location update**: Batched 2-4 separate UPDATE queries into single `update!` in `update_from_player_claim`

### Code quality (bez PRD)
- **Adventure DRY**: Extracted `next_available_clue_id` from duplicate `set_initial_clue`/`find_next_clue`

### Accessibility (bez PRD)
- Added `aria-label` on all action buttons (Reveal Hint, Check Location, Claim, Force Claim)
- Added `aria-live="polite"` on hint section and location status div
- Added `role="status"`, `role="list"`, `role="dialog"` semantic attributes
- Added `<nav aria-label="Breadcrumb">` for adventure navigation

### PRDs drafted (čekaju odobrenje)
- **PRD-0002**: Landing Page & Public Access — nav bar + public hunt browsing
- **PRD-0003**: Adventure Lifecycle — abandon adventure + pagination
- **PRD-0004**: Payment System — paid hunts checkout flow

### Testovi
- Prije: 403 tests, 1151 assertions
- Poslije: 412 tests, 1175 assertions (+9)
- System tests: 11 (unchanged, all passing)
- Novi: password length (2), 0-clue hunt guard (1), login error rendering (1), session fixation (1), Turbo 303 redirects (2), signup short password (1), signup Turbo redirect (1)

## [2026-04-07] improvement-loop | Session 4 — PRD implementations (0002, 0003, 0004)

### Kategorija: full (PRD-driven feature implementation)

### PRD-0002: Landing Page & Public Access — Done
- **FR-1**: `/hunts` now public (no auth required), hunt show public, "Log in to Start" for unauthenticated
- **FR-2**: Nav bar always visible — unauthenticated: logo + Hunts + Log In + Sign Up; authenticated: logo + Hunts + Admin + email + Logout
- Created `hunts/index.html.erb` (new view)
- Updated `HuntsController` — removed `require_login`, public index/show
- Updated `application.html.erb` — unified nav for all auth states

### PRD-0003: Adventure Lifecycle Management — Done
- **FR-1**: Abandon adventure — `abandoned: 3` enum status, `DELETE /adventures/:id/abandon` route, confirmation modal (no browser confirm), redirect to hunt page
- **FR-2**: Past adventures pagination — 5 per page, Previous/Next controls, "Showing X-Y of Z"
- Updated `Adventure` model, `AdventuresController`, `adventures/show.html.erb`, `hunts/show.html.erb`, routes

### PRD-0004: Payment System with Stripe Checkout — Done
- **ADR-0002**: Stripe as payment provider (accepted)
- Added `stripe` gem (v19.0.0)
- Created `Purchase` model (user, hunt, amount_cents, stripe_session_id, stripe_payment_intent_id, status enum)
- Created `CheckoutsController` — Stripe Checkout Session flow, success callback with payment verification
- Created `WebhooksController` — Stripe webhook with signature verification, `checkout.session.completed` handler
- Payment gate in `AdventuresController#create` — paid hunts require completed purchase
- Hunt show: "Purchase & Play — $XX.XX" button for paid hunts, "Start Adventure" for free/purchased
- Hunt model: `paid?`, `purchased_by?(user)` helpers
- Config: `config/initializers/stripe.rb`, env vars: STRIPE_SECRET_KEY, STRIPE_PUBLISHABLE_KEY, STRIPE_WEBHOOK_SECRET

### Testovi
- Prije: 412 tests, 1175 assertions
- Poslije: 429 tests, 1214 assertions (+17)
- System tests: 11 (all passing, updated for new nav bar)
- Novi: Purchase model (7), payment gate (2), purchase bypass (1), abandon adventure (2), hunt paid?/purchased_by? (5)

## 2026-10-03 — CI fix: herb native extension ABI mismatch

- **Problem**: nakon dodavanja `herb` gem-a (#14), `scan_js`, `lint_erb`, `test` i `system-test` padaju pri boot-u: `Failed to load the Herb native extension (LoadError)`. Precompiled `herb-0.11.0-x86_64-linux-gnu` ne učitava se na GitHub Actions Ruby 3.4.0 (`3.4.0+1` ABI) — isti problem kao ranije sa nokogiri/ffi.
- **Fix**: `gem "herb", "~> 0.11.0", force_ruby_platform: true` + uklonjene platform-specifične herb varijante iz `Gemfile.lock` (isti pattern kao nokogiri). Source build traži samo C compiler (ubuntu-latest i Dockerfile `build-essential` ga imaju).
- **Validacija**: frozen `bundle install`, `herb analyze` (36 clean), `@herb-tools/linter` (0 offenses), `importmap audit`, rubocop (0 offenses), 419 tests green.
- **Pravilo**: svaki novi gem sa native ekstenzijom dodaj sa `force_ruby_platform: true` dok je `.ruby-version` 3.4.0.
