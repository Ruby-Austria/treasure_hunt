# Architecture & Product Decisions

Compressed record of all ADRs and PRDs. Original documents removed 2026-04-13.

## Architecture Decisions

**ADR-0001: Spec-Driven Development** (Accepted, 2026-04-07)
Use ADR/PRD documents before implementing features. Prevents ad-hoc builds and gives AI agents implementation context.

**ADR-0002: Stripe as Payment Provider** (Accepted then removed, 2026-04-07)
Chose Stripe Checkout for PCI compliance. Implemented, then removed entirely when platform narrowed to free conference use.

**ADR-0003: Pin a stable Ruby patch release** (Accepted, 2026-10-03)
`.ruby-version` pinned to 3.4.11 (Dockerfile `RUBY_VERSION` matches). `3.4.0` resolved on GitHub Actions (`ruby/setup-ruby`) to a `3.4.0dev` pre-release snapshot, which broke prebuilt native gems (nokogiri, ffi, herb → `force_ruby_platform`) and crashed the interpreter at boot (`[BUG] rb_sys_fail(opendir)` in bootsnap). Bump patch releases deliberately, keeping CI and Docker on the same version. On 3.4.11 the `force_ruby_platform` workarounds were removed; native gems install prebuilt binaries again.

## Product Decisions (chronological)

**PRD-0001: UI Redesign** (Done, 2026-04-07)
Converted all 20 view templates from inline CSS to Tailwind classes per DESIGN.md. Zero inline styles.

**PRD-0002a: Landing Page & Public Access** (Done, 2026-04-07)
Made hunt listing public (no login required). Added consistent nav bar for unauthenticated users.

**PRD-0002b: RubyConf.at Edition** (Done, 2026-04-13)
Narrowed platform to RubyConf Austria 2026. Removed signup, payments UI, generic browsing. Added conference branding, bulk attendee registration. Admin manages all accounts.

**PRD-0003: Adventure Lifecycle** (Done, 2026-04-07)
Added abandon adventure (with confirmation modal) and past adventures pagination. Lets players recover from stuck states.

**PRD-0004: Payment System** (Done then removed, 2026-04-07)
Stripe checkout for paid hunts. Purchase model, webhook handler. Removed entirely when platform went conference-only (all hunts free).

**PRD-0005: Teams** (Done, 2026-04-13)
Team formation via invite codes. Shared clue progress across members. Can't leave team after treasure claimed (anti-spoiler). Supports solo and team play.

**PRD-0006: Leaderboard** (Done, 2026-04-13)
Public per-hunt rankings by clues solved. Paginated (5 per page). Shows current user position. Widget on dashboard.

**PRD-0007: Endgame Treasure Reveal** (Done, 2026-04-13)
Solve all clues → see treasure location + access code. Anti-screenshot (watermark + user-select:none). Email delivery. Admin marks claimed. All team members see same info.

**PRD-0008: UX Overhaul** (Done, 2026-04-13)
Split landing/dashboard. Removed difficulty display. Made team status prominent. Mobile-first for outdoor use. Improved empty states and onboarding.

**PRD-0009: Release Prep** (Done, 2026-04-13)
PWA (service worker, manifest, install prompt). Branded error pages (404/500). Email templates. Docker/Kamal deploy verification.

**PRD-0010: Playthrough UX Improvements** (Done, 2026-04-13)
From 10-persona browser testing: temperature feedback for all players, abandon button relocated to header, "Treasure Available" dashboard badge, 44px touch targets (WCAG).

## Removed Features

- **Stripe/Payments**: Full checkout flow removed — all hunts are free for conference
- **AI/Gemini**: Content generation services removed — clues authored directly
- **Google Places API**: Location discovery removed — venues are known conference locations
- **Nominatim geocoding**: Removed with Places API
- **Signup flow**: Removed — admin registers attendees
