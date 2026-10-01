# Playbook - Kako se gradi funkcionalnost u ovom projektu

Trajno znanje o pattern-ima, konvencijama i načinu rada u TreasureHunt.io.
Ovo se ne mijenja često i služi kao referenca za svaku implementaciju.

## Segmenti

| # | Segment | Opis |
|---|---------|------|
| 1 | [Modeli](01-modeli.md) | Struktura modela, validacije, asocijacije, enum-i, scope-ovi, Ruby idiomi |
| 2 | [Servisi](02-servisi.md) | Service object pattern-i, orkestracija, error handling |
| 3 | [Kontroleri](03-kontroleri.md) | Controller pattern-i, auth, JSON API, Turbo HTTP statusi, 37signals konvencije |
| 4 | [Views, Hotwire i Stimulus](04-views-stimulus.md) | Turbo Drive/Frames/Streams, Stimulus lifecycle/targets/values/outlets, UX feedback, forme |
| 5 | [Baza podataka](05-baza.md) | Migracije, indeksi, JSONB, geografski tipovi |
| 8 | [Testiranje](08-testiranje.md) | TDD RED-GREEN-REFACTOR, fixture-i, model/service/controller/system testovi, Brakeman |
| 9 | [Rute i autentifikacija](09-rute-auth.md) | Routing pattern-i, auth helper-i, namespace-ovi |
| 10 | [Code Quality i Debugging](10-code-quality.md) | Sandi Metz pravila, Ruby idiomi, systematic debugging, Brakeman, RuboCop |

## Izvori znanja

Playbook pattern-i su izvedeni iz:
- Stvarnog koda ovog projekta
- [superpowers-ruby](https://github.com/lucianghinda/superpowers-ruby) — Hotwire skills, TDD, Sandi Metz, 37signals, systematic debugging
- Rails Guides i Rails Way konvencije
- DESIGN.md za vizualne konvencije
