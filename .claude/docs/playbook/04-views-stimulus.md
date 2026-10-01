# Segment 4: Views, Hotwire i Stimulus

## View struktura

```
app/views/
├── layouts/
│   ├── application.html.erb    # Glavni layout (Tailwind)
│   └── admin.html.erb          # Admin layout (Tailwind, sidebar)
├── pages/index.html.erb        # Homepage (javna)
├── home/index.html.erb         # Dashboard (auth)
├── hunts/
│   ├── index.html.erb
│   └── show.html.erb
├── adventures/show.html.erb    # Gameplay view
├── sessions/new.html.erb       # Login
├── users/new.html.erb          # Signup
└── admin/                      # Admin CRUD views
```

## Styling konvencije

- **Tailwind CSS** utility klase - nikad inline stilovi
- **DESIGN.md** je referentni dokument za sve vizualne odluke
- **Semantičke boje:** blue=hunts, green=clues/success, purple=locations, orange=cities, red=errors
- **Responsive breakpoints:** sm:640px, md:768px, lg:1024px, xl:1280px
- **Layout:** max-w-6xl za javne stranice, sidebar layout za admin

---

## Turbo Drive

Turbo Drive je aktivan po defaultu. Svi linkovi i forme koriste Turbo navigaciju.

### Pravila

- **Ne disabliraj Turbo** osim za specifične edge case-ove (`data-turbo="false"`)
- **Cache-aware rendering**: čisti transient state prije cache snapshot-a
- **Forward/back navigacija**: UI mora biti korektan iz cache-a

## Turbo Frames

Za parcijalni render unutar stranice bez full page reload-a.

### Forme sa validacijom

```erb
<%= turbo_frame_tag "hunt_form" do %>
  <%= form_with model: [:admin, @hunt], local: true do |form| %>
    <% if @hunt.errors.any? %>
      <%# Error blok se renderuje in-place unutar frame-a %>
    <% end %>
    <%# ... form fields ... %>
  <% end %>
<% end %>
```

### HTTP status kodovi za Turbo forme

```ruby
# Controller - OBAVEZNO za Turbo kompatibilnost
def create
  @hunt = Hunt.new(hunt_params)
  if @hunt.save
    redirect_to admin_hunt_path(@hunt), notice: "Created.", status: :see_other  # 303
  else
    render :new, status: :unprocessable_entity  # 422 - Turbo renderuje in-place
  end
end
```

**Pravilo:** Uvijek `status: :unprocessable_entity` (422) za failed form validation, `status: :see_other` (303) za successful redirect. Bez ovih statusa Turbo ne zna kako reagovati.

### Lazy-loaded frames

```erb
<%= turbo_frame_tag "stats", src: stats_path, loading: :lazy do %>
  <p class="text-gray-400">Loading...</p>
<% end %>
```

## Turbo Streams

Za real-time update-ove i multi-target DOM manipulacije.

### Dostupne akcije

| Akcija | Ponašanje |
|--------|-----------|
| `append` | Dodaj na kraj kontejnera |
| `prepend` | Dodaj na početak |
| `replace` | Zamijeni cijeli element |
| `update` | Zamijeni inner HTML |
| `remove` | Ukloni element |
| `before` | Dodaj ispred elementa |
| `after` | Dodaj iza elementa |

### Pravila za Turbo Streams

1. **Preferiraj standardne akcije** prije custom-a
2. **Streams moraju biti mali i determinističi** - ne embedaj arbitrarne skripte
3. **Target mora postojati u DOM-u** prije stream-a
4. **Broadcast pattern** za cross-tab/cross-user sync:

```ruby
# Model
after_create_commit -> { broadcast_append_to "adventures" }

# View
<%= turbo_stream_from "adventures" %>
```

---

## Stimulus Fundamentals

### Controller lifecycle

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 1. Deklaracije (static) — uvijek na vrhu
  static values = {
    adventureId: Number,
    allHints: Array,
    cooldownMinutes: { type: Number, default: 30 }
  }

  static targets = ["revealHintBtn", "statusMessage", "hintsList"]

  static outlets = ["other-controller"]  // Povezivanje sa drugim kontrolerima

  static classes = ["active", "loading"]  // CSS klase iz HTML-a

  // 2. Lifecycle callbacks
  connect() {
    // DOM je spreman, element je u dokumentu
    // Inicijalizacija stanja, event listeneri, intervali
    this.isLoading = false
  }

  disconnect() {
    // Cleanup: clearInterval, removeEventListener, abort fetch
    if (this.interval) clearInterval(this.interval)
    if (this.abortController) this.abortController.abort()
  }

  // 3. Value change callbacks
  cooldownMinutesValueChanged() {
    // Automatski pozvan kada se value promijeni
    this.updateCooldownDisplay()
  }

  // 4. Target connected/disconnected callbacks
  statusMessageTargetConnected(element) {
    // Pozvan kad target element uđe u DOM
  }

  // 5. Action metode (public)
  async checkLocation() {
    // ...
  }

  // 6. Private metode
  #updateUI() {
    // Koristi private metode za interne operacije
  }
}
```

### Targets — Best Practices

```erb
<%# Target deklaracija u HTML-u %>
<div data-adventure-target="locationStatus" class="hidden"></div>

<%# Pristup u JS-u %>
this.locationStatusTarget          // Baca error ako ne postoji
this.locationStatusTargets         // Array svih matching elemenata
this.hasLocationStatusTarget       // Boolean check
```

**Pravila:**
- Koristi `has*Target` provjeru prije pristupa opcionalnim target-ima
- Nikad ne koristiti `querySelector` za elemente koji mogu biti targets
- Target imena su camelCase: `revealHintBtn`, `cooldownTimer`

### Values — Data binding

```erb
<%# Proslijeđivanje podataka iz Rails-a u Stimulus %>
<div
  data-controller="adventure"
  data-adventure-adventure-id-value="<%= @adventure.id %>"
  data-adventure-all-hints-value='<%= raw (@current_clue&.hints || []).to_json %>'
  data-adventure-last-hint-revealed-at-value="<%= @adventure.last_hint_revealed_at ? @adventure.last_hint_revealed_at.to_i * 1000 : 0 %>"
>
```

**Pravila:**
- **raw + to_json** za Arrays i Objects
- **Milisekunde** za timestamp values: `timestamp.to_i * 1000`
- Values su reaktivni — `*ValueChanged()` callback se poziva automatski
- Koristi default vrijednosti: `{ type: Number, default: 30 }`

### Actions — Event handling

```erb
<%# Standardni click %>
<button data-action="click->adventure#revealRandomHint">Reveal Hint</button>

<%# Keyboard event %>
<input data-action="input->search#filter keydown.enter->search#submit">

<%# Custom event %>
<div data-action="ajax:success->form#handleSuccess">
```

**Pravila:**
- Format: `event->controller#method`
- `click->` je default za button/a, `input->` za input/textarea, `submit->` za form
- Koristi `keydown.escape`, `keydown.enter` za specifične tastere

### Outlets — Inter-controller komunikacija

```erb
<div data-controller="search"
     data-search-results-outlet="#results-container">
  <input data-action="input->search#filter">
</div>

<div id="results-container" data-controller="results">
  <%# search controller može pristupiti results controller-u %>
</div>
```

```javascript
// U search controller-u
static outlets = ["results"]

filter() {
  this.resultsOutlet.updateList(this.query)
}
```

---

## Fetch pattern za JSON API pozive

```javascript
async myAction() {
  if (this.isLoading) return
  this.isLoading = true

  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || ''

  try {
    const response = await fetch(`/adventures/${this.adventureIdValue}/endpoint`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ param: value })
    })

    if (!response.ok) throw new Error(`HTTP ${response.status}`)

    const data = await response.json()
    this.handleResponse(data)
  } catch (error) {
    this.showError("Request failed")
  } finally {
    this.isLoading = false
  }
}
```

### CSRF token — OBAVEZNO

```javascript
const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || ''
headers: { 'X-CSRF-Token': csrfToken }
```

---

## UX Feedback Patterns

### Loading states

```javascript
// Koristi Turbo-native busy atribute PRIJE custom rješenja
// <form> dobija [aria-busy="true"] tokom submita

// Za custom loading:
startLoading() {
  this.checkLocationBtnTarget.disabled = true
  this.checkLocationBtnTarget.textContent = "Checking..."
  this.checkLocationBtnTarget.classList.add("opacity-50", "cursor-not-allowed")
}

stopLoading() {
  this.checkLocationBtnTarget.disabled = false
  this.checkLocationBtnTarget.textContent = "Check if I'm Close"
  this.checkLocationBtnTarget.classList.remove("opacity-50", "cursor-not-allowed")
}
```

**Pravila:**
- Disable button tokom request-a da spriječiš double-submit
- Koristi Tailwind klase za vizualni feedback (opacity-50, cursor-not-allowed)
- **Nikad ne koristi fixed timeout** kao proxy za network event — koristi realan callback
- **Symmetrical locking**: svaki `startLoading()` mora imati `stopLoading()` u finally bloku

### Optimistic UI

```javascript
// Prikaži rezultat odmah, rollback na error
claimClue() {
  // Optimistički update
  this.claimBtnTarget.textContent = "Claimed!"
  this.claimBtnTarget.classList.replace("bg-green-600", "bg-gray-400")

  this.performClaim().catch(() => {
    // Rollback
    this.claimBtnTarget.textContent = "Claim the Clue"
    this.claimBtnTarget.classList.replace("bg-gray-400", "bg-green-600")
  })
}
```

### Error display

```javascript
showError(message) {
  this.errorMessageTarget.textContent = message
  this.errorMessageTarget.classList.remove("hidden")
  // Auto-hide nakon 5 sekundi
  setTimeout(() => this.errorMessageTarget.classList.add("hidden"), 5000)
}
```

---

## Navigation & Content Patterns

### Tab switching sa URL state-om

```javascript
// URL i frame state su kanonični, NE click eventi
// Ažuriraj active state na load/render event, ne na click intent
// Validiraj ponašanje na forward/back i refresh

switchTab(event) {
  const tab = event.currentTarget.dataset.tab

  // Update URL bez full navigation
  const url = new URL(window.location)
  url.searchParams.set("tab", tab)
  history.pushState({}, "", url)

  // Update UI
  this.tabTargets.forEach(t => t.classList.toggle("active", t.dataset.tab === tab))
}
```

### Faceted search

```erb
<%= turbo_frame_tag "search_results" do %>
  <%# Rezultati pretrage %>
<% end %>

<form data-action="input->search#debounce" data-turbo-frame="search_results">
  <input name="q" data-action="input->search#filter">
</form>
```

```javascript
// Debounce keyboard input
debounce() {
  clearTimeout(this.timeout)
  this.timeout = setTimeout(() => this.element.requestSubmit(), 300)
}
```

---

## Geolocation API pattern

```javascript
navigator.geolocation.getCurrentPosition(
  (position) => {
    const { latitude, longitude, accuracy } = position.coords
    this.sendLocationCheck(latitude, longitude, accuracy)
  },
  (error) => {
    switch(error.code) {
      case error.PERMISSION_DENIED:
        this.showError("Location access denied. Please enable location services.")
        break
      case error.POSITION_UNAVAILABLE:
        this.showError("Location unavailable. Try again outside.")
        break
      case error.TIMEOUT:
        this.showError("Location request timed out. Please try again.")
        break
    }
  },
  { timeout: 10000, enableHighAccuracy: true }
)
```

---

## View konvencije

- **Tailwind CSS utility klase** za sav styling — nikad inline stilovi
- **DESIGN.md** je referenca za boje, spacing, tipografiju, komponente
- **Safe navigation** u ERB: `@model&.method`
- **raw + to_json** za proslijeđivanje podataka u Stimulus values
- **Milisekunde** za timestamp values: `timestamp.to_i * 1000`
- **Reload guard** u view-u: `@adventure.reload if @adventure.current_clue_id.present? && @adventure.current_clue.nil?`
- **classList.toggle('hidden')** umjesto `style.display` za show/hide
- **content_tag** umjesto `html_safe` za generisani HTML

---

## Povezani segmenti

- [03-kontroleri](03-kontroleri.md) - Kontroleri koji renderuju view-ove i obrađuju JSON pozive
- [09-rute-auth](09-rute-auth.md) - Rute na koje Stimulus šalje fetch pozive
- [10-code-quality](10-code-quality.md) - Sandi Metz pravila i Ruby idiomi
