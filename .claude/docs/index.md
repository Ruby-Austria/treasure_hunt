# TreasureHunt.io - Knowledge Base Index

---

## Decisions

All architecture and product decisions compressed into a single file.

| Stranica | Opis |
|----------|------|
| [decisions](decisions.md) | 2 ADRs + 11 PRDs — what was built, what was decided, what was removed |

## Playbook (kako se gradi)

Implementation patterns. 8 segments (AI and external API segments removed with dead code).

| Stranica | Opis | Ključne riječi |
|----------|------|----------------|
| [01-modeli](playbook/01-modeli.md) | Modeli, enum-i, validacije, asocijacije, scope-ovi | model, enum, validacija, scope, callback |
| [02-servisi](playbook/02-servisi.md) | Service object pattern-i | service, call, success?, error |
| [03-kontroleri](playbook/03-kontroleri.md) | Controller hijerarhija, auth, JSON API, Turbo | controller, before_action, require_login, turbo |
| [04-views-stimulus](playbook/04-views-stimulus.md) | Turbo, Stimulus, UX feedback, forme | stimulus, turbo, view, data-controller, fetch |
| [05-baza](playbook/05-baza.md) | Migracije, GPS precision, JSONB, indeksi | migration, index, jsonb, decimal |
| [08-testiranje](playbook/08-testiranje.md) | TDD, fixture-i, testovi, Brakeman | test, tdd, fixture, minitest, brakeman |
| [09-rute-auth](playbook/09-rute-auth.md) | Routing, session auth, namespace | routes, auth, session, namespace |
| [10-code-quality](playbook/10-code-quality.md) | Sandi Metz, Ruby idiomi, debugging, RuboCop | sandi metz, debugging, rubocop, security |

## Log

| Stranica | Opis |
|----------|------|
| [log](log.md) | Chronological activity log |

---

_Zadnje ažuriranje: 2026-04-13_
