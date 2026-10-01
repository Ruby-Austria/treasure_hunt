# Segment 3: Kontroleri

## Hijerarhija kontrolera

```
ApplicationController          # Auth helperi, error handling, Rollbar
├── PagesController            # Javne stranice (root)
├── SessionsController         # Login/logout
├── UsersController            # Signup
├── HuntsController            # Pregledanje huntova (auth required)
├── AdventuresController       # Gameplay (auth required)
├── StatsController            # JSON API (javni)
└── Admin::BaseController      # Admin layout + auth
    ├── Admin::DashboardController
    ├── Admin::HuntsController
    ├── Admin::CluesController
    └── Admin::LocationsController
```

## ApplicationController pattern

```ruby
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  helper_method :current_user, :logged_in?, :admin?
  rescue_from StandardError, with: :handle_error

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in? = !!current_user
  def admin? = logged_in? && current_user.admin?

  def require_login
    redirect_to login_path, alert: "You must be logged in" unless logged_in?
  end

  def require_admin
    redirect_to root_path, alert: "You must be an admin" unless admin?
  end

  def handle_error(exception)
    Rollbar.error(exception, request: request, person: current_user)
    raise exception
  end
end
```

## Admin kontroleri

Nasljeđuju `Admin::BaseController` koji forsira login + admin:

```ruby
class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_login
  before_action :require_admin
end

class Admin::HuntsController < Admin::BaseController
  before_action :set_hunt, only: [:show, :edit, :update, :destroy]

  def index
    @hunts = Hunt.order(created_at: :desc)
  end

  def create
    @hunt = Hunt.new(hunt_params)
    if @hunt.save
      redirect_to admin_hunt_path(@hunt), notice: "Hunt was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_hunt = @hunt = Hunt.find(params[:id])

  def hunt_params
    params.require(:hunt).permit(:name, :description, :status, :difficulty, :price, :tag_list)
  end
end
```

## JSON API akcije

Za endpoint-e koje poziva Stimulus (fetch). Ownership se rješava scope-ovanjem u `set_adventure`:

```ruby
# before_action callback-i obezbjeđuju auth i scoping
before_action :set_adventure  # scope na current_user.adventures
before_action :require_ownership

def check_location
  # 1. Validacija parametara
  unless params[:latitude].present? && params[:longitude].present?
    render json: { error: "Location required" }, status: :bad_request
    return
  end

  # 2. Delegiraj servisu
  result = LocationCheckService.new(
    user_lat: params[:latitude],
    user_long: params[:longitude],
    clue_location: @adventure.current_clue.location,
    adventure: @adventure
  ).call

  render json: result
rescue StandardError => e
  Rails.logger.error("check_location error: #{e.class} - #{e.message}")
  render json: { error: "Location check failed" }, status: :internal_server_error
end

private

def set_adventure
  @adventure = current_user.adventures.includes(hunt: [:tags, :clues], current_clue: :location).find(params[:id])
end
```

## Cached JSON pattern (StatsController)

```ruby
def index
  stats = Rails.cache.fetch("platform_stats", expires_in: 5.minutes) do
    calculate_stats
  end
  render json: stats
end
```

## Turbo-compatible HTTP status kodovi

**OBAVEZNO za Turbo Drive/Frames kompatibilnost:**

| Situacija | Status | Konstanta |
|-----------|--------|-----------|
| Form validation failed | 422 | `:unprocessable_entity` |
| Successful redirect | 303 | `:see_other` |
| Unauthorized access | 401 | `:unauthorized` |
| Bad request (missing params) | 400 | `:bad_request` |
| Server error | 500 | `:internal_server_error` |

```ruby
# ISPRAVNO: Turbo renderuje form in-place na 422
def create
  @hunt = Hunt.new(hunt_params)
  if @hunt.save
    redirect_to admin_hunt_path(@hunt), notice: "Created.", status: :see_other
  else
    render :new, status: :unprocessable_entity
  end
end

# POGREŠNO: Turbo ne zna šta da radi bez eksplicitnog statusa
render :new  # Default 200 — Turbo misli da je success
```

## 37signals / Basecamp pattern-i

Konvencije observirane iz produkcijskog Basecamp/Hey koda:

1. **Thin controllers, fat models** — kontroler samo koordinira
2. **Jedan instancirani objekt po akciji** (Sandi Metz pravilo)
3. **Concerns za shared auth logiku**: `include Authenticatable`
4. **RESTful routing** — custom akcije samo kad REST nije dovoljan
5. **Hotwire-first** — preferiraj Turbo Frames/Streams nad custom JS
6. **Solid Queue** za background jobs umjesto Sidekiq
7. **Caching strategije**: fragment caching, Russian doll caching

## Pravila za kontrolere

1. **Thin controllers** — logika u servisima, ne u akcijama
2. **before_action** za set_model i auth provjere
3. **Ownership provjera** na početku svake akcije: `unless @model.user == current_user`
4. **Early return** sa `render + return` za error case-ove
5. **Service.new(...).call** pattern za pozivanje servisa
6. **status:** uvijek eksplicitno na error odgovorima (:unauthorized, :bad_request, :unprocessable_entity)
7. **Admin override** — admin? check za privilegirane akcije (force_claim)
8. **422 za form errors, 303 za redirect** — Turbo kompatibilnost
9. **respond_to** za endpoints koji serviraju i HTML i JSON

---

## Povezani segmenti

- [02-servisi](02-servisi.md) - Service objects koje kontroleri pozivaju
- [04-views-stimulus](04-views-stimulus.md) - View-ovi koje kontroleri renderuju, Stimulus koji poziva JSON akcije
- [09-rute-auth](09-rute-auth.md) - Routing i autentifikacijski guard-ovi
- [10-code-quality](10-code-quality.md) - Sandi Metz: 1 objekt po controller akciji
