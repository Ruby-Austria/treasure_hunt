# Segment 9: Rute i autentifikacija

## Routing pattern

```ruby
Rails.application.routes.draw do
  # 1. Health check (uvijek prvi)
  get "up" => "rails/health#show", as: :rails_health_check

  # 2. Javni API endpoint-i
  get "stats", to: "stats#index", defaults: { format: :json }

  # 3. Auth rute (ručno definirane, ne Devise)
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  get "signup", to: "users#new", as: :signup
  post "signup", to: "users#create"

  # 4. Autentificirane rute
  get "home", to: "home#index", as: :home

  # 5. Nested resources za kreiranje
  resources :hunts, only: [:index, :show] do
    resources :adventures, only: [:create]
  end

  # 6. Member rute za custom akcije
  resources :adventures, only: [:show] do
    member do
      post :check_location
      post :claim_clue
      post :force_claim
      post :increment_hint_usage
    end
  end

  # 7. Admin namespace
  namespace :admin do
    resources :locations
    resources :hunts
    resources :clues
    root "dashboard#index"
  end

  # 8. Root ruta (uvijek posljednja)
  root "pages#index"
end
```

## Autentifikacija

Ručna implementacija (bcrypt + session), bez Devise-a:

### Session management

```ruby
# Login
session[:user_id] = user.id

# Logout - koristimo reset_session (ne session.delete) za potpuno brisanje
reset_session

# Current user (memoizirano, find_by za graceful handling obrisanih korisnika)
@current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
```

### Rate limiting (Rails 8+)

Koristimo ugrađeni `rate_limit` API za zaštitu od brute force napada:

```ruby
# SessionsController - login
rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
  flash[:alert] = "Too many login attempts. Please try again later."
  redirect_to login_path
}

# UsersController - signup
rate_limit to: 5, within: 5.minutes, only: :create, with: -> {
  flash[:alert] = "Too many signup attempts. Please try again later."
  redirect_to signup_path
}
```

### Helper metode (dostupne u views)

```ruby
helper_method :current_user, :logged_in?, :admin?

def logged_in? = !!current_user
def admin? = logged_in? && current_user.admin?
```

### Before action guard-ovi

```ruby
before_action :require_login          # Samo ulogirani korisnici
before_action :require_admin          # Samo admini
before_action :set_model, only: [...]  # Load model za specifične akcije
```

## Nested vs member rute

- **Nested**: kreiranje child resursa - `POST /hunts/:hunt_id/adventures`
- **Member**: custom akcije na resursu - `POST /adventures/:id/check_location`
- **Collection**: custom akcije na kolekciji (nemamo ih još)

## JSON vs HTML

- **HTML**: standardne CRUD akcije, redirect sa notice/alert
- **JSON**: Stimulus-pozivane akcije, render json sa status kodom
- **defaults: { format: :json }** za čiste API endpoint-e (stats)

## Ownership provjera pattern

Preferirani pristup: **scope queries na `current_user`** umjesto post-load provjere:

```ruby
# DOBRO - Adventure se traži samo među korisnikovim adventures-ima (404 za tuđe)
def set_adventure
  @adventure = current_user.adventures.includes(...).find(params[:id])
end

# Za admin-only akcije koristi nescopiran pristup sa eksplicitnom auth provjerom
def set_adventure_admin
  @adventure = Adventure.includes(...).find(params[:id])
end
```

Backup ownership guard (za format-aware odgovor):
```ruby
def require_ownership
  return if @adventure.user == current_user || admin?
  respond_to do |format|
    format.html { redirect_to home_path, alert: "You don't have access." }
    format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
  end
end
```

`require_login` takođe podržava JSON format:
```ruby
def require_login
  unless logged_in?
    respond_to do |format|
      format.html { redirect_to login_path, alert: "You must be logged in." }
      format.json { render json: { error: "Authentication required" }, status: :unauthorized }
    end
  end
end
```

---

## Povezani segmenti

- [03-kontroleri](03-kontroleri.md) - Kontroleri koji koriste auth helper-e i before_action guard-ove
- [01-modeli](01-modeli.md) - User model sa admin? flag-om i has_secure_password
- [04-views-stimulus](04-views-stimulus.md) - View-ovi koji koriste helper_method (current_user, logged_in?, admin?)
