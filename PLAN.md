# GeoQuest: AI Chronicles - Product Plan

**Version:** 3.0 (Unified Product Vision & Implementation Plan)
**Date:** 2026-01-03
**Status:** Ready for Implementation
**Purpose:** Single Source of Truth for PM Agent

---

## CODEBASE OVERVIEW & QUICK START

### Technology Stack Summary

**Backend**: Rails 8.1.1, PostgreSQL, Solid Stack (Queue/Cache/Cable)
**Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS Pro, DaisyUI, PWA
**AI (Planned)**: RubyLLM, Google Gemini, Google Places API
**Tools**: Rubocop, acts_as_taggable_on, Docker, Kamal

### Core Data Models (Current MVP)

1. **User** - Authentication, admin roles, trust scores
2. **Location** - GPS coordinates with radius-based zones, confidence scores, community learning
3. **Hunt** - Collection of clues, themes, difficulty levels, AI-generated metadata
4. **Clue** - Individual hunt steps, riddles, hints, story bridges
5. **Adventure** - Player progress, token-based claim verification

### Development Team Agents

The project uses specialized AI agents for code review:

| Agent | Command | Purpose |
|-------|---------|---------|
| **Tech Lead** | `/tech-review` | Code quality, architecture, security, performance |
| **Product Manager** | `/product-review` | Product vision alignment, user/business value |
| **QA Engineer** | `/qa-review` | Edge cases, security testing, destructive testing |
| **User Persona** | `/user-feedback` | UX feedback from different user perspectives |

**Agent documentation**: [.claude/](.claude/) folder

### Development Workflow

```
1. Before: Understand → Search codebase → Plan → /product-review (if significant)
2. During: Code incrementally → Follow Rails conventions → /tech-review (for architecture)
3. After: Tests → /tech-review → /qa-review → /user-feedback (UI) → Fix → Commit
```

### Current State

✅ **Working**: Auth, GPS checking (Haversine), claim verification, hints with cooldown, admin CRUD, Solid Stack configured

❌ **Missing**: AI integration, probabilistic location model, Hunt Factory, offline PWA, proximity feedback

### Key Files

- **Models**: [app/models/](app/models/) - User, Location, Hunt, Clue, Adventure
- **Schema**: [db/schema.rb](db/schema.rb) - Database structure
- **Routes**: [config/routes.rb](config/routes.rb) - Application routing
- **Tests**: [test/](test/) - Test suite
- **Agents**: [.claude/](.claude/) - Development agent prompts

---

## Executive Summary

**Product Vision**: Build the world's largest database of AI-generated, location-based experiences.

**Mission**: Create a self-service platform and automated "Hunt Factory" that enables generation of location-based treasure hunts anywhere in the world at scale using AI, Google Places API, and intelligent clustering algorithms.

**Core Principle**: Platform-first, global coverage, AI-driven content generation with infinite scale potential.

**Key Differentiator**: Not a curated city-by-city treasure hunt app - it's a **database and generation platform** that can create hunts anywhere on demand.

---

## HOMEPAGE & PLATFORM SHOWCASE

### Homepage Design Philosophy

**Key Message**: "World's largest database of location-based experiences"

**Primary Goal**: Showcase the **scale and reach** of the platform, not specific curated content

### Homepage Hero Section

```
┌─────────────────────────────────────────────────────┐
│                                                      │
│    World's Largest Database of                     │
│    Location-Based Experiences                      │
│                                                      │
│    [Real-time Stats Display]                       │
│    ┌──────────┬──────────┬──────────┬──────────┐   │
│    │ 1,247    │ 6,842    │ 12,456   │ 89       │   │
│    │ Hunts    │ Clues    │ Locations│ Cities   │   │
│    └──────────┴──────────┴──────────┴──────────┘   │
│                                                      │
│    [Generate Hunt Anywhere] [Browse Database]      │
└─────────────────────────────────────────────────────┘
```

### Stats Counter Requirements

**Must Display (Live from Database):**
1. **Total Hunts** - `Hunt.approved.count`
2. **Total Clues** - `Clue.joins(:hunt).where(hunts: { status: :approved }).count`
3. **Total Locations** - `Location.count`
4. **Cities Covered** - `Location.distinct.count(:city)` or `Hunt.approved.distinct.count('center_lat, center_lng')` grouped by proximity

**Optional Stats (Phase 2):**
- Countries covered
- Total adventures completed
- Active players (last 30 days)
- Hunts generated this week

### Implementation Details

**Backend (Stats Controller):**
```ruby
# app/controllers/stats_controller.rb
class StatsController < ApplicationController
  def index
    render json: {
      hunts: Hunt.approved.count,
      clues: Clue.joins(:hunt).where(hunts: { status: :approved }).count,
      locations: Location.count,
      cities: Location.distinct.pluck(:city).compact.size
    }
  end
end
```

**Caching Strategy:**
- Cache stats for 5 minutes (Solid Cache)
- Update cache on hunt approval
- Real-time feel without performance hit

**Frontend (Stimulus Counter):**
- Animated counter on page load (count up effect)
- Fetch stats via Turbo Frame or AJAX
- Update every 30 seconds (optional live updates via Solid Cable)

### Homepage Sections (Below Hero)

**1. How It Works**
- 3-step process: Pick location → AI generates → Play
- Visual flowchart

**2. Featured Hunts** (Optional, Phase 2)
- Showcase 3-6 random high-rated hunts
- From different cities/countries
- Not city-specific - global variety

**3. Generate On-Demand CTA**
- "Generate a hunt in [your city]"
- Input: city name
- Output: Hunt generated or added to queue

**4. Social Proof**
- User testimonials (when available)
- Number of hunts played today/this week

---

## BUSINESS MODEL & MONETIZATION STRATEGY

### Hunt Types (Simplified)

**Single Hunt Type:** `for_fun` only
- ❌ REMOVED: "reward" / competitive hunt distinction (over-complication)
- ✅ Difficulty levels: 1-5 (Family → Mastermind)
- ✅ All hunts have same structure: riddles, hints, story bridges
- ✅ Simplicity for users: "Choose difficulty, play hunt"

### Pricing Tiers

#### 🆓 FREE Plan

**Includes:**
- **3 free hunts** (lifetime trial) - enough to experience platform
- Solo play only (no team features)
- Access to global individual leaderboard
- Full hunt experience (hints, story, GPS navigation)

**After Trial:**
- **€5 per additional hunt** (à la carte)
- Once purchased = permanent access to that hunt
- Can buy unlimited hunts individually
- **Owned hunts persist even if user upgrades → downgrades**

**Example:**
- User plays 3 free hunts
- Buys 5 more hunts (€25 total)
- Decides to upgrade to Pro for 3 months
- Downgrades back to Free
- **Still has access to:** 5 purchased hunts (3 free trial is consumed)

---

#### ⭐ SUPPORTER/PRO Plan (Individual)

**Pricing:**
- **€7/month**
- **€60/year** (save €24 = 29% discount)

**Includes:**
- ✅ **Unlimited access** to ALL hunts (current + future)
- ✅ All platform updates and new features
- ✅ Team features (Phase 2):
  - Create team (base includes 1 member = you)
  - Add team members: **€5/person/month** or **€30/person/year**
  - Team leaderboard & collaborative play
  - Shared progress tracking

**Value Proposition:**
- Break-even at **13+ hunts/year** vs pay-per-hunt
- Target: Local explorers, families, enthusiasts
- Tourists likely prefer pay-per-hunt (2-5 hunts per city)

**Example Team Pricing (4 people):**
- Monthly: €7 (owner) + €15 (3 members × €5) = **€22/month**
- Yearly: €60 (owner) + €90 (3 members × €30) = **€150/year** (save €114)

---

#### 👥 TEAM Plan (Large Groups - Phase 2)

**For:** Tour operators, schools, corporate events, large families

**Pricing:** (TBD in Phase 2, estimated)
- **€99/year for up to 20 people**
- **€5/additional person/year** beyond 20
- Volume discounts for 50+ members

**Includes:**
- Everything from Pro plan
- Team management dashboard
- Custom branding options (Phase 3)
- Priority support
- Analytics & reporting

**Target Market:**
- Tourism agencies
- Schools & universities
- Corporate team building
- Family reunions (extended families)

---

### Monetization Philosophy

**MVP (First 6 months):** GROWTH OVER REVENUE
- Focus: Build 500+ hunts, get 1000+ users
- All features free during beta (optional)
- Collect testimonials & usage data
- Validate pricing with early adopters

**Scale (6+ months):** FREEMIUM CONVERSION
- Target conversion: 5-10% Free → Pro
- Target ARPU (Average Revenue Per User): €3-5/month
- Primary revenue: Pay-per-hunt (tourists) + Pro subscriptions (locals)

**Long-term:** B2B OPPORTUNITIES
- Tourism boards: Custom city campaigns
- Museums: Educational hunts
- Events: Conference treasure hunts
- Sponsorships: Local businesses featured in hunts

---

### Revenue Projections (Conservative)

**Month 6 (Post-MVP):**
- 1,000 users
- 50 Pro subscribers (5% conversion) = €350/month
- 200 hunt purchases/month = €1,000/month
- **Total: ~€1,350/month** (covers API costs + infra)

**Month 12:**
- 5,000 users
- 300 Pro subscribers (6% conversion) = €2,100/month
- 500 hunt purchases/month = €2,500/month
- 10 Team plans (€99/year) = €80/month
- **Total: ~€4,680/month** (sustainable, can hire)

**Month 24:**
- 20,000 users
- 1,500 Pro subscribers (7.5% conversion) = €10,500/month
- 1,500 hunt purchases/month = €7,500/month
- 50 Team plans = €412/month
- 3-5 B2B custom hunt contracts = €1,000-2,000/month
- **Total: ~€19,500-20,500/month** (profitable, scale team)

---

## USER EXPERIENCE ARCHITECTURE

### Design Approach

**Mobile-First Philosophy:**
- Primary target: smartphone users walking around cities
- All pages must be fully responsive
- Desktop is secondary (mostly for admin and planning)
- Touch-optimized interactions
- Offline-capable (Phase 2+)

**Guest vs Authenticated Experience:**
- ✅ Guests can browse hunts without signup
- ✅ Anti-bot protection on public pages (rate limiting)
- ❌ Guests cannot start hunts (signup required)
- ✅ Google OAuth + email/password authentication

---

### Page Structure & Navigation

#### PUBLIC PAGES (Guest Access)

**1. Homepage (Dual Purpose)**

**For Logged-Out Users:**
- Hero: "World's Largest Database of Location-Based Experiences"
- Live stats counter (Hunts, Clues, Locations, Cities) with animated Stimulus controller
- How It Works section
- Featured hunts carousel
- Social proof (testimonials, player count)
- CTA buttons: "Start Playing" → signup

**For Logged-In Users (Personalized Dashboard):**
- Redirect from `/` to dashboard view
- **If active adventure exists:**
  - Show most recent adventure card
  - "Continue Adventure" button (prominent)
  - Progress indicator (e.g., "Clue 5 of 7")
- **If NO active adventure:**
  - Primary CTA: "Start Random Nearby Hunt" button
    - Requires: geocoder gem for location-based search
    - Uses device GPS to find hunts within 5km radius
  - Secondary: "Browse All Hunts" link
  - Display: 3 most popular hunts currently being played
- Quick stats widget:
  - Adventures completed
  - Favorites count
  - Global rank (if applicable)

**2. Hunt Browse/Discovery Page** (`/hunts`)
- Available to guests AND logged-in users
- Anti-bot crawling protection (rate limiting)
- **Filters:**
  - Difficulty (1-5 stars)
  - Location/City (nearby, specific city, country)
  - Tags/categories (Historical, Mystery, Family-Friendly, etc.)
  - Sort by: Popular, New, Nearby, Difficulty, Rating
- Search box (hunt title, description, city)
- **Hunt cards display:**
  - AI-generated preview image
  - Title, difficulty level
  - City/region
  - Estimated time (e.g., "45-60 min")
  - Number of clues (e.g., "7 clues")
  - Favorites counter ("♥ 247 favorites")
  - Average rating (⭐ 4.5 / 5)
- **SEO Strategy - Static Location Pages:**
  - `/hunts/austria` - all hunts in Austria (pre-filtered)
  - `/hunts/vienna` - all hunts in Vienna (pre-filtered)
  - `/hunts/zagreb`, `/hunts/paris`, etc.
  - Better SEO ranking, shareable URLs
  - Pre-rendered with location filters applied

**3. Hunt Detail Page** (`/hunts/:id`)
- Hunt title, description, theme/story
- Difficulty level (visual stars)
- City/region, country
- **Preview map:**
  - Shows approximate hunt area (polygon/circle)
  - Does NOT reveal exact clue locations
  - Helps users understand walking distance
- Estimated time range (e.g., "45-90 minutes")
- Number of clues, total walking distance estimate
- Tags (clickable to browse similar hunts)
- **"Add to Favorites" button:**
  - Heart icon (filled if already favorited)
  - Counter: "247 people favorited this hunt"
- **Primary CTA:**
  - If logged in: "Start This Hunt" button → creates Adventure
  - If guest: "Sign Up to Play" button → signup flow
- **Hunt-Specific Leaderboard:**
  - Top 10 fastest completions
  - Player name (or anonymous), completion time, hints used
  - Highlight current user's rank if they've completed it
- **Ratings & Reviews:**
  - Average star rating (⭐ 4.5 / 5) with review count
  - Recent reviews (Phase 2)
- **Open Question:** How much to reveal vs keep mysterious?
  - Show sample riddle to entice users?
  - Or keep all riddles hidden until playing?

**4. Leaderboards Page** (`/leaderboards`)
- **Global Player Leaderboard:**
  - Top 100 players worldwide
  - Ranked by: Total adventures completed, combined time, success rate
  - Columns: Rank, Player name, Avatar, Adventures completed, Total time, Success rate
  - "That's you!" indicator for current user
  - Pagination for ranks beyond 100
- **Per-Hunt Leaderboards:**
  - Embedded on hunt detail pages (see above)

---

#### AUTHENTICATED PAGES (Login Required)

**5. Hunt Gameplay Page** (`/adventures/:id`) ✅ Already Exists
- Active adventure interface:
  - Current clue riddle (text + AI-generated image)
  - Progress indicator: "Clue 3 of 7"
  - Story bridge from previous clue (narrative continuity)
  - **"Check Location" button** (GPS-based verification)
  - **Proximity feedback:** "Getting warmer/colder" indicators
  - **Request Hint button:**
    - Shows cooldown timer if recently used
    - Displays hint when available
  - **Map widget:**
    - Shows user's current location (blue dot)
    - Does NOT show target location (keeps mystery)
    - Optional: proximity circle (visual aid)
  - **Abandon Hunt** option (with confirmation)

**6. My Adventures Page** (`/adventures`)
- List of all adventures played by current user
- **Status filters (tabs):**
  - In Progress
  - Completed
  - Abandoned (optional)
- **Each adventure card shows:**
  - Hunt title, city
  - Status badge (color-coded)
  - Progress bar (e.g., "5/7 clues solved")
  - Started date
  - Completed date (if finished) + total time
  - Hints used count
  - **Action buttons:**
    - In Progress: "Continue" (green button)
    - Completed: "View Results" or "Play Again"
- **Empty state:** "You haven't started any adventures yet. Browse hunts to begin!"

**7. My Favorites Page** (`/favorites`)
- Grid/list of all hunts user has favorited
- Same card layout as Browse page
- **"Remove from Favorites"** option (heart icon toggle)
- **"Start Hunt"** button on each card
- **Empty state:** "You haven't favorited any hunts yet. Browse hunts to find adventures you like!"

**8. User Settings/Profile Page** (`/settings`)
- **Account Information:**
  - Email address (change email with verification)
  - Password (change password, requires current password)
  - Google account connection status
    - If connected: "Connected to Google: you@example.com" + "Disconnect" option
    - If not connected: "Connect Google Account" button
- **Email Preferences:**
  - ☑ Hunt completion notifications (on/off)
  - ☑ Weekly digest of new hunts (on/off, Phase 2)
  - ☑ Team invitations (on/off, Phase 2)
- **Profile Settings (Phase 2):**
  - Display name (public)
  - Avatar upload
  - Bio (optional)
  - Public stats visibility toggle
- **Subscription Management (Phase 2):**
  - Current plan badge (FREE / PRO / TEAM)
  - Upgrade/downgrade options
  - Add team members (PRO users only)
  - Payment method (Stripe integration)
  - Billing history (invoices download)

---

#### AUTHENTICATION PAGES

**9. Login Page** (`/login`)
- Email + password fields
- **"Login with Google"** button (OAuth, prominent)
- "Forgot password?" link
- "Don't have an account? Sign up" link
- Mobile-friendly form layout

**10. Signup Page** (`/signup`)
- Email + password fields (password strength indicator)
- **"Sign up with Google"** button (OAuth, prominent)
- Email verification required after signup (Mailgun)
- Terms of Service & Privacy Policy checkboxes
- "Already have an account? Log in" link

**11. Password Reset Flow** (`/password_reset`)
- Email input form
- Mailgun sends password reset link
- Reset token validation (expires after 24h)
- New password form (with confirmation field)
- Success message → redirect to login

---

#### ADMIN PAGES (Admin Role Required)

**12. Admin Dashboard** (`/admin`)
- All existing admin functionality from current codebase
- Hunt CRUD (create, edit, delete, approve/reject)
- Location CRUD
- Clue CRUD with sequence ordering
- Hunt Factory controls:
  - Manual trigger button for hunt generation
  - TargetQueue management (Phase 1)
  - Generation logs and status
- User management (view, edit roles, ban/unban)
- System stats dashboard:
  - Total hunts, clues, locations, cities
  - Active users, adventures in progress
  - API usage (Google Places, Gemini)
  - Database size, performance metrics

---

### Navigation Structure

**Header (Logged-Out Users):**
- Logo (links to homepage)
- Browse Hunts
- Leaderboards
- Login button (secondary style)
- Sign Up button (primary style)

**Header (Logged-In Users):**
- Logo (links to personalized dashboard)
- Browse
- My Adventures
- Favorites
- Leaderboards
- Profile/Settings dropdown (avatar icon)
  - My Profile
  - Settings
  - Logout

**Mobile Navigation:**
- **Responsive design** - switches based on device type:
  - **Desktop/Web devices**: Hamburger menu (traditional web pattern)
  - **Mobile devices**: Bottom navigation bar (mobile app pattern)
    - Icons: Home, Browse, Adventures, Favorites, Profile
    - Fixed position at bottom for thumb-friendly access
  - Detect device type using Stimulus controller or CSS media queries

**Footer (All Pages):**
- About TreasureHunt.io
- Contact / Support
- Terms of Service
- Privacy Policy
- API Documentation (Phase 2+)
- Social media links (optional)

---

### Technical Implementation Requirements

**1. Geocoder Gem** ✅
- Required for "nearby hunt" search functionality
- Reverse geocoding: lat/lng → city/country names
- Distance calculations (complements existing Haversine formula)
- Usage:
  ```ruby
  # Find hunts within 5km of user's location
  Hunt.near([user_lat, user_lng], 5, units: :km)
  ```

**2. Google OAuth Integration** ✅
- Add `omniauth-google-oauth2` gem
- Configure OAuth 2.0 credentials (Google Cloud Console)
- Implement OAuth callback controller (`/auth/google_oauth2/callback`)
- Handle account linking:
  - If email exists: link Google account to existing user
  - If new: create user with Google OAuth (skip email verification)
- Settings page: Connect/disconnect Google account

**3. Anti-Bot Protection** ✅
- Rate limiting on browse page (Rack::Attack gem)
  - Max 60 requests per minute per IP
  - Stricter limits for unauthenticated requests
- Prevent automated scraping of hunt data:
  - Require authentication for certain endpoints
  - Obfuscate hunt IDs (UUIDs instead of sequential integers)
- Optional: Captcha on signup (evaluate necessity during beta)
  - Recommended: hCaptcha or reCAPTCHA v3

**4. SEO Static Pages** ✅
- Dynamic routes for location-based pages:
  - `/hunts/:country` (e.g., `/hunts/austria`)
  - `/hunts/:city` (e.g., `/hunts/vienna`)
- Pre-render with filters applied (country/city scope)
- Sitemap generation (`sitemap.xml`):
  - All public hunt pages
  - Location-based browse pages
  - Update daily (cron job or Solid Queue recurring task)
- Meta tags for each hunt (OpenGraph, Twitter Cards):
  - Title, description, preview image
  - Shareable on social media

**5. Mailgun Email Integration** ✅
- Transactional emails:
  - Email verification on signup (with token link)
  - Password reset emails (with token link)
  - Hunt completion notifications (optional user preference)
- Email templates (HTML + plain text fallback)
- Mailgun API configuration in `config/environments/production.rb`
- Testing in development (use Mailgun sandbox domain)

---

### UX Decisions Finalized ✅

1. **Navigation Pattern (Mobile):** ✅ DECIDED
   - Desktop/Web: Hamburger menu
   - Mobile: Bottom navigation bar
   - Responsive design switches based on device type

2. **Hunt Detail Page:** ✅ DECIDED
   - Use existing `description` field to create intrigue
   - **DO NOT reveal clues or riddles**
   - Keep mystery intact - only show theme, difficulty, general story
   - Example: "Follow the trail of Vienna's hidden coffee houses..."

3. **Anti-Bot Strategy:** ✅ DECIDED
   - **Rate limiting** (Rack::Attack) - MUST HAVE
   - **Captcha** (hCaptcha/reCAPTCHA v3) on signup - MUST HAVE
   - **Advanced protection**: Device fingerprinting, honeypot fields, behavior analysis, IP reputation, session validation

4. **Leaderboard Ranking:** ✅ DECIDED
   - **Weighted score formula**:
     ```
     Player Score = (Adventures Completed × 100)
                   + (Avg Difficulty × 50)
                   - (Avg Hints Used × 10)
                   + (Success Rate % × 20)
                   - (Avg Completion Time penalty)
     ```
   - Rewards high play rate, difficulty, and efficiency

5. **Hunt Preview Map:** ✅ DECIDED - REMOVED
   - No map on hunt detail page
   - **Map during gameplay only**:
     - Leaflet.js (free, open-source, lightweight)
     - Shows user's current location (blue dot)
     - Does NOT show target location
     - Optional: Approximate search radius as visual hint
     - Purpose: Help user navigate, not reveal answer

6. **AI Image Generation:** ✅ DECIDED - REMOVED
   - No AI-generated images (legal liability concern)
   - Use placeholder images or free stock photos (Unsplash, Pexels)
   - Admin can upload images for curated hunts (Phase 2+)

---

## 1. PRODUCT PHILOSOPHY (Non-Negotiable)

### Global-First Design
- Hunts must work in any country, city, or region
- Locations are probabilistic, not perfectly precise
- Accuracy is handled by game design, not hard guarantees
- AI is trusted by default, with optional human correction
- "For fun" hunts dominate: low friction, high scale

### Core Philosophy
**"We don't ask where exactly you are. We ask: are you in the right place to feel the story?"**

### What We Optimize For
- Speed of content generation
- Global coverage
- Zero marginal cost
- Experience over precision

### What We Explicitly Do NOT Optimize For
- Perfect GPS accuracy
- Military-grade location validation
- Anti-cheat perfection
- Hard geographic correctness

**This is an adventure platform, not navigation software.**

---

## 2. COMPETITIVE ADVANTAGE

### Traditional Competitors:
- Need verified POIs
- Need manual maps
- Need exact coordinates
- City-by-city expansion
- High cost per hunt

### GeoQuest Approach:
- AI invents locations automatically
- Probabilistic zones with radius
- Optional Google Places (AI-first)
- Global from day 1
- Zero marginal cost
- Ship content faster
- Cover the world
- Let AI + players improve data over time
- Focus on experience, not precision

### Key Differentiators
1. **Speed**: Generate 100+ hunts per day vs. weeks manually
2. **Scale**: Any city, any country, unlimited
3. **Cost**: No location curation, minimal API calls
4. **Improvement**: Community refines data passively
5. **UX**: GPS imprecision becomes gameplay feature

---

## 3. CORE ARCHITECTURE (Rails 8 PWA)

### Technology Stack (Non-Negotiable)

#### Backend Stack
- **Rails 8.1.1** - Latest version, utilize all new features
- **PostgreSQL** - Only database, use JSONB for flexible metadata
- **Solid Stack** (Rails 8 native):
  - **Solid Queue** - Background jobs (Hunt Factory, validations)
  - **Solid Cache** - Caching (API responses, fragments)
  - **Solid Cable** - Real-time WebSocket updates

#### Frontend Stack
- **Hotwire** - Turbo + Stimulus, no heavy JS frameworks
- **Stimulus** - ALL JavaScript logic MUST be in Stimulus controllers
- **Tailwind CSS (Pro)** - Styling with DaisyUI components
- **PWA Only** - NO native mobile apps, Progressive Web App only
- **Service Worker** - Offline functionality and caching

#### AI & External APIs
- **RubyLLM** - Ruby gem for AI integration
- **Google Gemini** - Content generation (riddles, stories, narratives)
- **Google Places API** - Location discovery and validation

#### Code Quality (Mandatory)
- **Rubocop** - Required for all code, no commits without passing
- **DRY Principle** - Don't Repeat Yourself, extract common code
- **SOLID Principles** - Single Responsibility, Open/Closed, etc.
- **Rails Conventions** - Follow Rails Way, no reinventing the wheel

#### Feature Management
- **Flipper** - Feature flags for:
  - Hunt Factory on/off in production
  - A/B testing new features
  - Gradual feature rollouts
  - Kill switch for problematic features

#### Architectural Principles
- **API is Source of Truth** - Backend makes all decisions
- **Thin Controllers** - Logic goes in services/models
- **Service Objects** - For complex operations
- **Query Objects** - For complex database queries
- **Form Objects** - For complex forms
- **Presenter/Decorator** - For view logic

#### What to NEVER Use
- ❌ React, Vue, Angular or any JS framework
- ❌ Native mobile apps (iOS/Android)
- ❌ MySQL, SQLite, MongoDB in production
- ❌ Sidekiq (use Solid Queue)
- ❌ Redis for cache (use Solid Cache)
- ❌ ActionCable without Solid Cable
- ❌ Inline JavaScript (must be Stimulus)
- ❌ Inline CSS (must be Tailwind)
- ❌ Code without Rubocop check
- ❌ God objects and fat controllers

### Offline-First Strategy
- **Service Worker**: Offline-first experience
- **IndexedDB**: Queue 'Claim' requests when offline
- **Background Sync**: POST data once online

### Key Services Architecture

```
app/services/
├── ai/
│   ├── gemini_client.rb
│   ├── riddle_generator.rb
│   ├── story_bridge_generator.rb
│   └── image_prompt_generator.rb
├── hunt_factory/
│   ├── orchestrator.rb
│   ├── location_scout.rb
│   ├── route_optimizer.rb
│   └── content_generator.rb
├── google_places_service.rb
├── location_validation_service.rb
└── claim_clue_service.rb

app/jobs/
├── hunt_generation_job.rb
├── location_refinement_job.rb
└── cleanup_expired_tokens_job.rb
```

---

## 4. LOCATION MODEL: ZONES, NOT PINS

### Key Insight
A location is a **search area**, not a single GPS coordinate.

### Location Attributes
```ruby
Location:
  - name (string)
  - description (text)
  - lat (decimal, precision: 10, scale: 7)
  - lng (decimal, precision: 10, scale: 7)
  - radius (integer, meters)
  - confidence_score (decimal, 0-1, default: 0.5)
  - verification_state (enum: ai_generated, auto_verified, human_verified)
  - usage_count (integer, default: 0)
  - avg_player_lat (decimal)
  - avg_player_lng (decimal)
  - city (string)
  - country (string)
  - metadata (jsonb)
  - google_place_id (string, nullable)
  - address (string, nullable)
  - difficulty (enum: 1-5)
```

### Radius Strategy
Radius compensates for uncertainty:

| Verification Level | Radius |
|-------------------|--------|
| AI-generated only | 150–300m |
| Auto-verified | 75–150m |
| Human-verified | 25–50m |
| Competitive hunts | <20m |

### Browser GPS Reality
Browser GPS accuracy:
- ~5–20m outdoors (best case)
- ~30–100m urban
- ~100–1000m indoors / poor signal

**Therefore:**
- Never require pixel-perfect GPS
- Match player location to radius
- Location detection = probabilistic match

---

## 5. AI-FIRST LOCATION CREATION (MCP)

### MCP Responsibilities
AI is allowed to:
- Invent interesting, public, pedestrian-safe locations
- Estimate approximate latitude/longitude
- Generate: clues, hints (optional, free hunts only), narratives, tags, themes
- Assign country/region as text, not foreign keys

### MCP Prompt Constraints
AI must:
- Avoid private property
- Prefer well-known or culturally interesting places
- Assume locations are approximate
- Include confidence score for coordinates

### Automated Location Validation
System performs:
- Reverse geocoding (OSM / offline geocoder)
- Country match validation
- Reject obvious errors: ocean, restricted areas, uninhabited regions
- Tag suspicious locations as `draft`

### Approval Flow
- Valid → auto-approved
- Suspicious → admin review (optional)
- Admin can correct lat/lng anytime

---

## 6. HUNT FACTORY - Autonomous AI Generation System

### Factory Logic Overview

**1. Target Selection**
- Priority check in TargetQueue table
- If empty, activate "Global Explorer Mode" (discover new cities)

**2. Location Scouting ("Seed & Satellite" Strategy)**
- **Database First**: Always check Locations table before calling Google Places API
- Find seed location (interesting point in target city)
- Discover satellite locations within 2.5km radius
- Ensure all points within walking cluster

**3. Haversine Validation**
- Calculate total walking distance between all steps
- **Discard hunts exceeding 3km total distance**
- Optimize step sequence for logical walking route

**4. Difficulty Scaling (1-5)**

| Level | Mode | Characteristics |
|-------|------|-----------------|
| 1-2 | Family | Simple rhymes, enthusiastic tone, "Bonus Action Tasks" (jump, count, dance) |
| 3 | Classic | Balanced history and riddles, moderate difficulty, educational |
| 4-5 | Mastermind | Cryptic puzzles, wordplay, obscure historical details, micro-observations |

**5. AI Content Generation**
- **Personas**: Random assignment per hunt (Noir Detective, Happy Scout Dog, Ancient Monk, Time Traveler, Ghost Hunter, Pirate Captain)
- **Riddles**: Gemini generates themed riddles based on location history/features
- **Story Bridges**: Narrative continuity between steps
- **Images**: DALL-E 3/Imagen prompts generated for each step
- **Metadata**: Store generation prompts and parameters

---

## 7. CLAIM LOGIC & GAMEPLAY

### Core Claim Logic
Player claims a clue when:
```ruby
distance(player_position, location.lat/lng) <= location.radius
```

Using:
- Haversine formula (no external API calls)
- Server-side validation only
- Client only displays progress feedback

### UX That Absorbs Inaccuracy

**Never Show:**
- "You are exactly here"
- Exact meters remaining

**Show Instead:**
- "You're getting closer"
- "Explore this area"
- Progress bar
- Heat / proximity indicators
- Compass-like hint

**Imprecision becomes gameplay**

### Community-Driven Accuracy (Passive Learning)

Each successful claim:
- Stores player GPS position
- Updates rolling averages: `avg_player_lat`, `avg_player_lng`

When enough players succeed:
- System re-centers location automatically
- Confidence score increases
- Radius can shrink

**Collective intelligence without explicit moderation**

---

## 8. SECURITY & ANTI-CHEAT (Forensic Backend)

### Offline-First Claim System
- User claims location offline
- PWA saves "Evidence Packet" to IndexedDB:
  - `location_id`, GPS coordinates, timestamp
  - Answer to riddle/question
  - Device fingerprint

### Backend Validation (Solid Queue Job)
1. **Distance Check**: Haversine distance <= location.radius
2. **Velocity Check**: Verify player didn't travel faster than humanly possible between steps
3. **Integrity Check**: HMAC signatures or hidden location-based answers prevent spoofing
4. **Trust Score**: Track player reliability over time
5. **Pattern Analysis**: Detect suspicious behavior (impossible speeds, GPS jumping)

### Trust Score System
- Starts at 1.0
- Decreases with suspicious patterns
- Increases with consistent, valid claims
- Low trust score → stricter validation

### Rate Limiting
- Max claims per hour per user
- Max hunts started per day
- Cooldown between failed attempts

---

## 9. HUNT ACCESS & PAYMENT SYSTEM

### Simplified Model: Single Hunt Type

**All hunts are "for_fun" type with 5 difficulty levels (1-5)**
- ❌ REMOVED: Separate "competitive" or "reward" hunt types
- ✅ Unified experience: All hunts have hints, leaderboards, story bridges
- ✅ Radius varies by verification level (150-300m AI-generated, 25-50m verified)

### User Access Tiers

#### FREE Users
- **3 free hunts** (lifetime trial)
- Pay **€5 per additional hunt** (permanent access)
- Solo play only
- Global individual leaderboard access

#### PRO Users (€7/month or €60/year)
- **Unlimited access** to all hunts
- All platform updates
- **Team features (Phase 2+)**:
  - Create team
  - Add members: €5/person/month or €30/person/year
  - Team leaderboard
  - Collaborative/competitive play modes

#### TEAM Plan (Phase 2+)
- **€99/year for up to 20 people**
- Team management dashboard
- Analytics & reporting
- Custom branding options (Phase 3)

### Hunt Ownership Rules

**Key Principle:** Once purchased, always owned

1. **Free users who buy à la carte:**
   - Hunt purchase = permanent access
   - Upgrades/downgrades don't affect owned hunts

2. **Pro users who downgrade:**
   - Keep all hunts purchased individually before Pro
   - Lose unlimited access (back to 3 free limit)
   - Can buy additional hunts à la carte again

**Example Flow:**
```
User starts Free → plays 3 free hunts → buys 2 hunts (€10)
→ upgrades to Pro (3 months) → plays 50 hunts
→ downgrades to Free
→ **Still has access to:** 2 purchased hunts (not the 50 played during Pro)
→ 3 free hunts already consumed, must buy more à la carte
```

### Payment Integration (Phase 2+)

**MVP:** All hunts free during beta
**Post-MVP:** Stripe integration for:
- One-time hunt purchases
- Monthly/yearly Pro subscriptions
- Team member add-ons

---

## 10. DATABASE SCHEMA

### Core Models

#### Locations
```ruby
- id (bigint)
- name (string)
- description (text)
- lat (decimal, precision: 10, scale: 7)
- lng (decimal, precision: 10, scale: 7)
- radius (integer, meters, default: 200)
- confidence_score (decimal, default: 0.5)
- verification_state (enum: ai_generated, auto_verified, human_verified)
- usage_count (integer, default: 0)
- avg_player_lat (decimal)
- avg_player_lng (decimal)
- google_place_id (string)
- address (string)
- city (string)
- country (string)
- difficulty (enum: 1-5)
- metadata (jsonb)
- timestamps
```

#### TargetQueue
```ruby
- id (bigint)
- city (string)
- country (string)
- hunts_to_generate (integer)
- hunts_generated_count (integer, default: 0)
- priority (integer, default: 0)
- processed (boolean, default: false)
- last_generated_at (datetime)
- metadata (jsonb)
- timestamps
```

#### Hunts
```ruby
- id (bigint)
- name (string)
- description (text)
- theme (string)
- persona (string) # e.g., 'Noir Detective', 'Happy Scout Dog', 'Ancient Monk'
- difficulty (enum: 1-5)
- scope (string) # e.g., 'Walking Cluster'
- center_lat (decimal)
- center_lng (decimal)
- total_distance_meters (integer)
- estimated_duration_min (integer)
- price (decimal, default: 0.0)
- hunt_type (enum: for_fun, reward)
- status (enum: draft, approved, archived)
- language (string, default: 'en')
- completion_message (text)
- ai_generated (boolean, default: false)
- generation_metadata (jsonb)
- timestamps
```

#### Clues
```ruby
- id (bigint)
- hunt_id (bigint, FK)
- location_id (bigint, FK)
- sequence_number (integer)
- description (text) # The riddle/clue
- riddle (text) # AI-generated clue text
- reasoning (text) # Story bridge
- story_bridge (text) # Narrative connection to next step
- hints (json array)
- fun_fact (text)
- bonus_task (string) # For kids: "jump 5 times", etc.
- image_url (string)
- difficulty (enum: 1-5)
- proximity_feedback (boolean, default: true)
- metadata (jsonb)
- timestamps
```

#### Adventures (Player Progress)
```ruby
- id (bigint)
- user_id (bigint, FK)
- hunt_id (bigint, FK)
- current_clue_id (bigint, FK)
- clue_ids (json array)
- solved_clue_ids (json array)
- revealed_hints (json array)
- hints_used (integer, default: 0)
- status (enum: in_progress, completed)
- current_clue_claim_token (string)
- current_clue_claim_token_expires_at (datetime)
- last_hint_revealed_at (datetime)
- timestamps
```

#### PlayerClaims / ClaimAttempts (Forensic Evidence)
```ruby
- id (bigint)
- adventure_id (bigint, FK)
- clue_id (bigint, FK)
- location_id (bigint, FK)
- player_lat (decimal)
- player_lng (decimal)
- accuracy (float) # GPS accuracy from browser
- distance_from_target (decimal, meters)
- claimed_at (datetime)
- evidence_packet (jsonb) # GPS, timestamp, answer hash, device info
- device_fingerprint (string)
- velocity_check_passed (boolean)
- integrity_check_passed (boolean)
- trust_score (decimal)
- success (boolean)
- timestamps
```

#### Users
```ruby
- id (bigint)
- email (string)
- password_digest (string)
- admin (boolean, default: false)
- trust_score (decimal, default: 1.0)
- display_name (string)
- bio (text)
- avatar_url (string)
- timestamps
```

---

## 11. CURRENT STATE ASSESSMENT

### What's Working (MVP Foundation)

**User Management**
- [x] Authentication (bcrypt)
- [x] Session management
- [x] Admin roles

**Hunt Gameplay**
- [x] GPS location checking (Haversine)
- [x] Claim verification (token-based)
- [x] Progressive clue solving
- [x] Hint system with cooldown
- [x] Adventure completion tracking

**Admin Tools**
- [x] Hunt CRUD
- [x] Location CRUD
- [x] Clue CRUD
- [x] Basic tagging

**Infrastructure**
- [x] Rails 8 + PostgreSQL
- [x] Solid Queue/Cache/Cable configured
- [x] Docker + Kamal deployment
- [x] CI/CD pipeline
- [x] acts_as_taggable_on for Hunts and Locations

### What's Missing (Critical Gaps)

**AI Integration**
- [ ] RubyLLM gem integration
- [ ] Google Gemini API setup
- [ ] Google Places API integration
- [ ] Prompt engineering for riddles
- [ ] Image generation pipeline

**Probabilistic Location Model**
- [ ] Location radius field
- [ ] Confidence scoring
- [ ] Verification states
- [ ] Community learning (avg player position)
- [ ] Auto-validation logic

**Hunt Factory**
- [ ] TargetQueue model
- [ ] HuntGenerationJob (Solid Queue)
- [ ] Seed & Satellite location logic
- [ ] Haversine validation (3km limit)
- [ ] Difficulty scaling (personas)
- [ ] Factory admin dashboard

**UX Enhancements**
- [ ] Proximity feedback (hot/cold)
- [ ] "Getting closer" indicators
- [ ] Hunt discovery with tags
- [ ] Rating system

---

## 12. IMPLEMENTATION PHASES

### Phase 1: AI Foundation & Probabilistic Locations (Weeks 1-4)

**Goal**: Integrate AI generation, implement probabilistic location model, test with manual triggers

#### Week 1: Setup & Integration

**AI Integration**
- [ ] Add RubyLLM gem to Gemfile
- [ ] Configure Google Gemini API credentials
- [ ] Configure Google Places API
- [ ] Create `app/services/ai/` directory structure
- [ ] Implement `AI::GeminiClient` service
- [ ] Implement `AI::GooglePlacesClient` service
- [ ] Write tests for API integrations

**Database Migrations**
- [ ] Migration: Add radius, confidence_score, verification_state to Locations
- [ ] Migration: Add avg_player_lat, avg_player_lng to Locations
- [ ] Migration: Add metadata (jsonb) to Locations
- [ ] Migration: Add theme, persona, center_lat/lng, ai_generated to Hunts
- [ ] Migration: Add sequence_number, riddle, story_bridge, image_url, bonus_task to Clues
- [ ] Migration: Create TargetQueue table
- [ ] Migration: Create PlayerClaims table
- [ ] Run migrations, verify schema

**Deliverables**: AI clients ready, database schema enhanced

#### Week 2: Location Intelligence

**Probabilistic Location System**
- [ ] Update `Location` model with new validations
- [ ] Add enum for `verification_state`
- [ ] Implement `Location#within_radius?(lat, lng)` method
- [ ] Implement `Location#update_from_player_claim(lat, lng)` (community learning)
- [ ] Implement `Location#auto_validate` (reverse geocoding)
- [ ] Add OSM/Nominatim reverse geocoding service
- [ ] Create `LocationValidationService`
- [ ] Write tests for location logic

**Google Places Integration**
- [ ] Implement `GooglePlacesService#find_interesting_places(lat, lng, radius)`
- [ ] Implement `GooglePlacesService#get_place_details(place_id)`
- [ ] Add caching with Solid Cache (1 week TTL)
- [ ] Handle API rate limits and errors
- [ ] Write tests

**Deliverables**: Probabilistic location system working, Google Places integrated

#### Week 3: AI Content Generation

**Riddle Generation**
- [ ] Create `AI::RiddleGenerator` service
- [ ] Implement persona-based prompts (Noir Detective, Scout Dog, etc.)
- [ ] Implement difficulty scaling (Family vs Mastermind)
- [ ] Test with Gemini API
- [ ] Add retry logic and error handling
- [ ] Store generation metadata (prompts used, tokens, etc.)

**Story Bridge Generation**
- [ ] Create `AI::StoryBridgeGenerator` service
- [ ] Generate narrative connections between clues
- [ ] Maintain persona consistency throughout hunt
- [ ] Test with sample locations

**Image Prompt Generation**
- [ ] Create `AI::ImagePromptGenerator` service
- [ ] Generate DALL-E style prompts based on location, theme, persona, difficulty
- [ ] Store prompts in metadata
- [ ] (Phase 2: actual image generation)

**Deliverables**: AI can generate riddles, story bridges, image prompts

#### Week 4: Manual Hunt Factory (Admin Triggered)

**Hunt Factory Service**
- [ ] Create `app/services/hunt_factory/` directory
- [ ] Implement `HuntFactory::Orchestrator` (main coordinator)
- [ ] Implement `HuntFactory::LocationScout` (Seed & Satellite logic)
- [ ] Implement `HuntFactory::RouteOptimizer` (Haversine, 3km limit)
- [ ] Implement `HuntFactory::ContentGenerator`
- [ ] Create admin UI: "Generate Hunt" button
- [ ] Write comprehensive tests

**Deliverables**: Admin can manually trigger AI hunt generation

---

### Phase 2: Autonomous Factory & Offline-First PWA (Weeks 5-8)

**Goal**: Autonomous background generation, offline capabilities, community learning

#### Week 5: Autonomous Background Jobs

**TargetQueue System**
- [ ] Implement `TargetQueue` model validations
- [ ] Create admin UI for TargetQueue management
- [ ] Implement `HuntGenerationJob` (Solid Queue)
- [ ] Configure recurring job (every 30 minutes)
- [ ] Add job monitoring

**Factory Dashboard (Real-time)**
- [ ] Create `Admin::FactoryDashboardController`
- [ ] Use Solid Cable for live updates
- [ ] Add pause/resume controls
- [ ] Add manual retry for failed generations

**Deliverables**: Factory runs autonomously 24/7

#### Week 6: Community Learning System

**Player Claim Tracking**
- [ ] Update `ClaimClueService` to create `PlayerClaim` records
- [ ] Store actual player GPS at claim time
- [ ] Store accuracy from browser
- [ ] Store device fingerprint

**Location Refinement**
- [ ] Implement `Location#refine_from_claims` method
- [ ] Calculate rolling average of player positions
- [ ] Update `avg_player_lat`, `avg_player_lng`
- [ ] Increase `confidence_score` based on usage
- [ ] Decrease `radius` as confidence increases
- [ ] Background job: `LocationRefinementJob` (daily)

**Trust Score System**
- [ ] Add `trust_score` to Users table
- [ ] Implement velocity checking
- [ ] Implement pattern analysis
- [ ] Adjust user trust_score based on behavior
- [ ] Weight claims by trust_score in refinement

**Deliverables**: Locations improve automatically over time

#### Week 7-8: Offline-First PWA

**Service Worker Setup**
- [ ] Update PWA manifest
- [ ] Implement Service Worker for offline caching
- [ ] Cache critical assets (CSS, JS, images)
- [ ] Cache hunt data for active adventures
- [ ] Implement cache-first strategy

**IndexedDB for Offline Claims**
- [ ] Create IndexedDB schema
- [ ] Implement offline claim workflow
- [ ] Implement Background Sync API

**Offline UX**
- [ ] Show offline indicator
- [ ] Show pending claims count
- [ ] Show sync status
- [ ] Handle sync errors gracefully

**Deliverables**: Full offline gameplay support

---

### Phase 3: Global Scale & Polish (Weeks 9-12)

**Goal**: Global discovery, ratings, social features, performance optimization

#### Week 9: Hunt Discovery & Search

- [ ] Enhance `acts_as_taggable_on` for Hunts
- [ ] Create `HuntsController#index` with filters
- [ ] Implement pagination (25 per page)
- [ ] Add search by name/description
- [ ] Hunt preview (first clue, area, difficulty, duration)
- [ ] Map integration (Mapbox or Google Maps)

**Deliverables**: Rich hunt discovery experience

#### Week 10: Ratings & Reviews

- [ ] Create `HuntRating` model
- [ ] Add rating UI after hunt completion
- [ ] Calculate and cache average ratings
- [ ] Add "helpful" voting on reviews
- [ ] Flag low-rated hunts for review

**Deliverables**: User feedback loop established

#### Week 11: Social & Gamification

- [ ] User profiles (display_name, bio, avatar)
- [ ] Achievement system
- [ ] Leaderboards (global, hunt-specific, monthly)

**Deliverables**: Engaging social features

#### Week 12: Performance & Polish

- [ ] Database indexes for common queries
- [ ] Eager loading optimization
- [ ] Query caching (Solid Cache)
- [ ] CDN for images
- [ ] Set up APM and monitoring
- [ ] Bug fixes and mobile responsiveness

**Deliverables**: Production-ready, performant platform

---

## 13. SUCCESS METRICS

### Phase 1 (Week 4)
- AI can generate complete hunt (5+ locations)
- Admin can trigger generation manually
- Generation success rate >80%
- Average generation time <2 minutes

### Phase 2 (Week 8)
- Factory generates 10+ hunts/day autonomously
- Offline claims work reliably
- Location confidence improves over time
- Zero Google Places API calls for existing locations

### Phase 3 (Week 12)
- 100+ AI-generated hunts live
- 1000+ registered users
- 50+ daily active users
- Average hunt rating >4.0 stars
- <500ms API response time (p95)

### Long-term (Month 6)
- 10,000+ hunts (100 cities, 50 countries)
- 10,000+ users
- 100+ daily active users
- Community-refined locations >1000
- Average confidence score >0.8

---

## 14. FIRST 1,000 GLOBAL HUNTS GENERATION STRATEGY

1. **Seed TargetQueue** with top 100 cities worldwide
2. **Priority**: Tourist destinations first (Paris, NYC, Tokyo, etc.)
3. **Difficulty Mix**: 40% easy, 30% medium, 20% challenging, 10% hard
4. **Hunt Type**: 80% for_fun, 20% reward
5. **Themes**: History, Mystery, Nature, Art, Food, Architecture, Legends
6. **Factory Loop**: Process 10 hunts/hour initially
7. **Auto-approval**: Confidence score > 0.7
8. **Human review**: Confidence score 0.4-0.7
9. **Auto-reject**: Confidence score < 0.4

---

## 15. PSYCHOLOGY OF ADDICTIVE 'FOR FUN' HUNTS

### Engagement Hooks
- **Story Arc**: Each hunt tells a complete narrative
- **Discovery**: Uncover hidden details about familiar places
- **Achievement**: Collect badges, streaks, completions
- **Social**: Share discoveries, compare times
- **Learning**: Fun facts and historical context
- **Variety**: Different themes, difficulties, locations

### Retention Mechanics
- **Daily Challenges**: New micro-hunts daily
- **Seasonal Events**: Special themed hunts
- **Leaderboards**: City, country, global
- **Unlock System**: Complete easier hunts to unlock harder ones
- **Collections**: Complete all hunts in a city/theme

---

## 16. COST ESTIMATION

### API Costs (Monthly at 1000 hunts/month)

| Service | Calculation | Cost |
|---------|-------------|------|
| Google Gemini | ~10K calls × $0.00025/1K tokens | ~$125 |
| Google Places (Nearby) | 10K searches × $0.032 | ~$320 |
| Google Places (Details) | 5K calls × $0.017 | ~$85 |
| DALL-E 3 (Phase 4) | 5K images × $0.04 | ~$200 |
| **Total API** | | **~$730** |

### Realistic Cost (with optimizations)
- Database-first reduces Google Places to ~30%
- Caching reduces duplicate calls by ~50%
- **Realistic: ~$300-400/month**

### Infrastructure
- Kamal + VPS: $50-100/month
- PostgreSQL hosting: $25-50/month
- Image storage: $10-20/month
- **Total infrastructure: ~$100/month**

**Grand Total: ~$500/month at scale**

---

## 17. RISK MITIGATION

### Technical Risks

| Risk | Mitigation |
|------|------------|
| AI generates bad riddles | Human review queue, quality scoring, iterative prompt improvement |
| Google API quota exceeded | Database-first, aggressive caching, rate limiting |
| GPS accuracy issues | Large radius (150-300m), proximity feedback, community refinement |
| Cheating/spoofing | Velocity checks, trust scores, pattern analysis |
| Performance at scale | Caching, indexes, CDN, background jobs |

### Product Risks

| Risk | Mitigation |
|------|------------|
| Low user adoption | Free tier, viral mechanics, referral program |
| Poor AI content quality | Continuous prompt improvement, human curation, ratings |
| Geographic bias | Start with tourist-heavy cities, expand globally |
| Seasonal usage | Indoor hunts, virtual components, year-round themes |

---

## 18. DEFINITION OF DONE

### Phase 1 Complete When:
- [ ] Admin can click "Generate Hunt" with city/theme
- [ ] AI generates 5+ location hunt in <2 minutes
- [ ] Riddles are coherent and difficulty-appropriate
- [ ] Locations pass validation (not ocean, etc.)
- [ ] Hunt is playable end-to-end
- [ ] All tests passing

### Phase 2 Complete When:
- [ ] Factory generates hunts automatically from queue
- [ ] Admin dashboard shows live progress
- [ ] Offline claim works without internet
- [ ] Background sync posts claims when online
- [ ] Locations improve from player data

### Phase 3 Complete When:
- [ ] Users can discover hunts by tags
- [ ] Users can rate completed hunts
- [ ] User profiles show achievements
- [ ] Platform handles 100+ concurrent users
- [ ] API response time <500ms (p95)

---

## 19. LAUNCH CRITERIA

**Ready for Public Beta when:**
- 100+ AI-generated hunts across 10+ cities
- All Phase 1-3 features complete
- <5 critical bugs
- Test users complete hunts successfully
- Average hunt rating >3.5 stars
- Documentation complete (README, FAQ, guides)
- Monitoring and alerts configured
- Mobile-responsive on iOS and Android

**Target Launch Date**: End of Week 12 (March 2026)

---

## 20. IMMEDIATE NEXT STEPS

### Week 1 Sprint Tasks (Start Monday)

1. **Setup** (Day 1-2)
   - [ ] Add `ruby-llm` gem
   - [ ] Get Google Gemini API key
   - [ ] Get Google Places API key
   - [ ] Configure credentials

2. **Database** (Day 2-3)
   - [ ] Write all migrations
   - [ ] Run migrations
   - [ ] Verify schema
   - [ ] Update models

3. **AI Integration** (Day 3-5)
   - [ ] Implement GeminiClient
   - [ ] Test with sample prompts
   - [ ] Implement GooglePlacesClient
   - [ ] Write tests

**End of Week 1 Goal**: API integrations working, database ready

---

**Document Status**: Approved - Ready for Implementation
**Last Updated**: 2026-01-03
**Next Review**: End of Week 4 (Phase 1 completion)
