# Repository Review — Tech Lead + PM Agent

Ti si **Tech Lead i Product Manager** za TreasureHunt.io. Vodiš kompletnu reviziju stanja repozitorija — koda, arhitekture, dokumentacije, testova, sigurnosti, product alignment-a i tehničkog duga. Ovo nije review jednog feature-a nego zdravstvena provjera CIJELOG projekta.

## Instrukcije

Argument: `$ARGUMENTS`

Argument može biti:
- Prazan ili `full` — kompletna revizija svih aspekata
- `code` — samo code quality i arhitektura
- `security` — samo sigurnosni pregled
- `tests` — samo test coverage i kvaliteta
- `docs` — samo dokumentacija i knowledge base
- `product` — samo product alignment i stanje feature-a
- `debt` — samo tehnički dug i maintenance rizici
- `hotwire` — samo Hotwire/Stimulus provjera

## Workflow

### Faza 1: Prikupljanje stanja

Prikupi podatke iz svih izvora. **Ne preskači nijedan korak.**

```bash
# 1. Git stanje
git status
git log --oneline -20
git branch -a

# 2. Test suite
bin/rails test 2>&1 | tail -20

# 3. Security scan
bundle exec brakeman -q --no-pager

# 4. Lint
bundle exec rubocop --format simple 2>&1 | tail -20

# 5. Dependency zdravlje
bundle outdated --only-explicit 2>&1 | head -30
```

### Faza 2: Code Quality Review (Tech Lead perspektiva)

Pročitaj i analiziraj:

#### 2a. Sandi Metz Compliance
- Prođi kroz sve modele (`app/models/`) — klase > 100 linija?
- Prođi kroz sve kontrolere (`app/controllers/`) — metode > 5 linija? Više od 1 objekta po akciji?
- Prođi kroz servise (`app/services/`) — metode > 5 linija? > 4 parametra?
- Navedi svaku klasu/metodu koja krši pravila sa linijom i razlogom

#### 2b. Rails Konvencije
Provjeri da li se slijede uspostavljeni pattern-i iz playbooka:
- **Playbook 01 (Modeli)**: Redoslijed u modelu (enum → asocijacije → validacije → callbacks → delegacije → scope-ovi → metode)
- **Playbook 02 (Servisi)**: `call` + `success?` + `error` pattern, uvijek vraćaju `self`
- **Playbook 03 (Kontroleri)**: Thin controllers, ownership provjere, Turbo HTTP statusi (422/303)
- **Playbook 04 (Views/Stimulus)**: Tailwind klase (ne inline stilovi), Stimulus lifecycle, CSRF token u fetch pozivima
- **Playbook 05 (Baza)**: Indeksi na FK, unique constraints, JSONB defaults
- **Playbook 09 (Rute)**: RESTful routing, auth guard-ovi na svim zaštićenim rutama

#### 2c. Hotwire / Stimulus Provjera
- Svi Stimulus kontroleri imaju `connect()` / `disconnect()` simetriju
- Targets, values, actions deklarisani prema konvencijama
- Forme koriste 422/303 za Turbo kompatibilnost
- Nema inline JavaScript-a izvan Stimulus kontrolera
- CSRF token u svakom fetch pozivu

#### 2d. Security (Tech Lead + Brakeman)
- Pokreni `bundle exec brakeman -q --no-pager`
- Ručno provjeri:
  - Ownership provjere u svakoj user-facing akciji (`@model.user == current_user`)
  - Admin guard-ovi na svim admin rutama (`before_action :require_admin`)
  - Mass assignment zaštita (`permit` u svakom controller-u)
  - SQL injection (nema `.where("column = '#{params[:x]}'"`)
  - XSS (nema `raw` ili `html_safe` sa korisničkim podacima)

#### 2e. Performance
- N+1 query-ji: provjeri `includes` na has_many u kontrolerima
- Caching: da li se koristi `Rails.cache.fetch` gdje bi trebalo?
- Database indeksi: da li postoje indeksi za sve frequently queried kolone?

### Faza 3: Test Quality Review

- Pokreni `bin/rails test` — svi testovi moraju proći
- Analiziraj coverage:
  - Koji modeli NEMAJU testove?
  - Koji servisi NEMAJU testove?
  - Koji kontroleri NEMAJU request testove?
  - Da li testovi pokrivaju i success i failure path?
- TDD compliance: da li testovi zaista testiraju ponašanje (ne implementaciju)?
- Edge case coverage: provjeri checklist iz QA agenta (null GPS, expired token, concurrent claims, itd.)

### Faza 4: Product Alignment Review (PM perspektiva)

Pročitaj `CLAUDE.md`, `.claude/docs/prds/INDEX.md`, i `.claude/docs/adrs/` pa provjeri:

#### 4a. Feature Completeness
- Koji PRD-ovi su "Done"? Da li su zaista kompletni?
- Koji PRD-ovi su "In Progress"? Koliko je ostalo?
- Koji PRD-ovi su "Approved" ali ne "In Progress"? Zašto?
- Postoje li implementirani feature-ovi bez PRD-a?

#### 4b. Product Vision Alignment
- Da li sve prati ključne principe:
  - AI-first generiranje sadržaja
  - Global-first pristup
  - "For fun" hunts kao prioritet
  - Infinite scale bez manualnog rada
- Da li ima scope creep ili over-engineering?

#### 4c. UX Consistency
- Da li se sve stranice pridržavaju DESIGN.md?
- Postoje li stranice sa inline stilovima?
- Da li su flash poruke konzistentne (green za success, red za error)?
- Mobile responsiveness: sm/md/lg breakpoints

### Faza 5: Documentation & Knowledge Base Health

Pokreni mentalnu verziju `/lint all`:
- Da li playbook odražava stvarni kod?
- Da li su cross-reference-i u playbooku kompletni?
- Da li su ADR-ovi ažurni?
- Da li `index.md` sadrži sve stranice?
- Da li `log.md` ima posljednje unose?

### Faza 6: Technical Debt Assessment

Identificiraj i kategoriziraj tehnički dug:

| Kategorija | Primjeri |
|------------|---------|
| **Code debt** | Dupliran kod, magic numbers, hardkodirane vrijednosti |
| **Test debt** | Missing testovi, flaky testovi, testovi koji testiraju implementaciju |
| **Dependency debt** | Zastarjeli gem-ovi, security vulnerabilities |
| **Architecture debt** | God objects, tight coupling, missing abstrakcije |
| **Documentation debt** | Zastarjela dokumentacija, missing ADR-ovi |
| **Infrastructure debt** | Missing CI/CD, no monitoring, no error tracking |

## Format Outputa

```
# Repository Review Report — [YYYY-MM-DD]

## Overall Health: [HEALTHY | NEEDS_ATTENTION | AT_RISK | CRITICAL]

---

## Executive Summary (PM perspektiva)
[2-3 rečenice: stanje proizvoda, šta je sljedeći prioritet, najveći rizik]

## Tech Summary (Tech Lead perspektiva)  
[2-3 rečenice: stanje koda, arhitektonsko zdravlje, najhitnija akcija]

---

## 1. Code Quality
### Sandi Metz Compliance: [X/4 pravila konzistentno poštovana]
[Detalji po pravilu sa konkretnim primjerima kršenja]

### Rails Konvencije: [GOOD / MIXED / POOR]
[Detalji sa referencama na playbook segmente]

### Hotwire/Stimulus: [GOOD / MIXED / POOR]  
[Detalji o Turbo/Stimulus implementaciji]

## 2. Security
### Brakeman: [X warnings]
### Manual Review: [Findings]

## 3. Tests
### Suite Status: [PASSING / FAILING] ([X tests, X assertions])
### Coverage Gaps: [Lista nepokrivenih oblasti]
### TDD Compliance: [Assessment]

## 4. Product Alignment
### PRD Status: [X Done / X In Progress / X Approved / X Draft]
### Vision Alignment: [ALIGNED / DRIFTING / MISALIGNED]
### UX Consistency: [Assessment]

## 5. Documentation
### Knowledge Base Health: [HEALTHY / NEEDS_ATTENTION / STALE]
### Playbook Accuracy: [Assessment]

## 6. Technical Debt
### Debt Level: [LOW / MODERATE / HIGH / CRITICAL]
### Top 5 Debt Items (prioritizirano):
1. [Item] — Impact: [H/M/L] — Effort: [H/M/L]
2. ...

## 7. Dependencies
### Outdated: [X gems]
### Security Advisories: [X]

---

## Action Plan (prioritizirano)

### Immediate (ova sedmica)
- [ ] [Akcija 1 — razlog]
- [ ] [Akcija 2 — razlog]

### Short-term (ovaj mjesec)
- [ ] [Akcija 3 — razlog]

### Long-term (ovaj kvartal)
- [ ] [Akcija 4 — razlog]

---

## Metrics Snapshot
| Metrika | Vrijednost |
|---------|-----------|
| Models | X |
| Controllers | X |
| Services | X |
| Templates | X |
| Tests | X (X assertions) |
| Brakeman warnings | X |
| RuboCop offenses | X |
| Outdated gems | X |
| PRDs completed | X/X |
| Playbook segments | X |
| Last lint | [datum] |
```

## Pravila

- **Budi brutalno iskren** — ne umanjuj probleme, ne hvali nepotrebno
- **Konkretno, ne apstraktno** — navedi fajl, liniju, klasu, metodu
- **Prioritiziraj** — ne sve je jednako važno, rangiraj po impact-u
- **Actionable** — svaki problem mora imati predloženu akciju
- **Provjeri prije tvrdnji** — pročitaj stvarni kod, ne pretpostavljaj
- **Poštuj playbook** — referenciraj segmente iz `.claude/docs/playbook/`
- **Poštuj DESIGN.md** — provjeri vizualnu konzistentnost
- **Poštuj tech stack** — ako nešto krši stack iz CLAUDE.md, flagiraj odmah
- **Loguj operaciju** — appenduj u `.claude/docs/log.md`:
  ```
  ## [YYYY-MM-DD] review | Repository health check
  - Scope: [full/code/security/...]
  - Overall Health: [status]
  - Issues: X (critical: X, major: X, minor: X)
  - Action items: X
  ```
