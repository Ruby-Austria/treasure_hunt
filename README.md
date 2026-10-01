# Treasure Hunt

A location-based treasure hunt platform for conferences, built with Rails 8.1. Originally created for [RubyConf Austria 2026](https://rubyconf.at), where attendees explored Vienna solving GPS-verified clues, and now open source so **any conference organizer can run their own hunt**.

Players walk the city with their phones: each clue unlocks when they get close to the real location. Teams, hints on cooldowns, live leaderboards, a real-world treasure endgame — all as an installable progressive web app that keeps working on shaky venue WiFi.

## For conference organizers

You don't need to be a Rails developer to run this. The short version:

1. **Clone and configure.** Edit [`config/conference.yml`](config/conference.yml) — event name, city, dates, theme color, logo. That's the whole rebrand.
2. **Create your hunts.** Deploy, log in as admin, and build hunts and clues in the admin UI — or write them as seed files.
3. **Learn from a real example.** [`examples/rubyconf-austria/`](examples/rubyconf-austria/) contains the two actual hunts that ran in Vienna (35 stops across the city, hand-validated coordinates and radii, hints tuned over weeks of playtesting). Read it to see what a good hunt looks like, or load it to try the app:
   ```bash
   bin/rails runner examples/rubyconf-austria/seeds.rb
   ```
4. **Deploy.** Docker + Kamal configuration included; any VPS will do. Player traffic at a conference is a few hundred phones — a small box is plenty.

### Design guidance

Writing good clues is the hard part, and it's not a code problem. See [`db/data/hunts_draft.md`](db/data/hunts_draft.md) and [`db/data/vienna_locations.md`](db/data/vienna_locations.md) for the working notes behind the Vienna hunts, including the hint policy (never name the place in a hint) and how radii were tuned per landmark.

## Features

- **GPS treasure hunts** — sequential clue solving with proximity-based verification
- **Team play** — form teams, share progress, claim treasure together
- **Hint system** — reveal hints with cooldown timers
- **Temperature feedback** — cold / closer / warm / hot proximity indicators
- **Live leaderboard** — per-hunt rankings
- **Treasure endgame** — solve all clues to reveal a real-world treasure location
- **Admin UI** — manage hunts, clues, locations, and attendees without touching code
- **Installable PWA** — home-screen app with offline support via service worker

## Tech stack

- **Backend:** Ruby 3.4 / Rails 8.1 / PostgreSQL
- **Frontend:** Hotwire (Turbo + Stimulus) / Tailwind CSS
- **Infra:** Docker + Kamal, Solid Queue/Cache/Cable
- **CI:** GitHub Actions

## Development

```bash
bin/setup                 # install deps, create db, seed
bin/rails runner examples/rubyconf-austria/seeds.rb   # load the example hunts
bin/dev                   # run the app (Procfile.dev)
bin/rails test            # test suite
```

Default admin login after seeding: `admin@treasurehunt.io` / `admin123456` (override with `ADMIN_PASSWORD`, change immediately in production).

Credentials: a placeholder `config/credentials.yml.enc` ships with a local `config/master.key` (gitignored). Regenerate before production with `EDITOR="nano" bin/rails credentials:edit`.

## Contributing

Issues and pull requests welcome. If you ran a hunt at your conference, tell us about it — and consider contributing your hunt as another example under `examples/`.

## License

[MIT](LICENSE). Originally built by [Muhamed Isabegovic](https://muhamed.at) for RubyConf Austria 2026.
