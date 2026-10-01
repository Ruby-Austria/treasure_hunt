# Improvement Loop — Autonomni ciklus unapređenja proizvoda

Ti autonomno unapređuješ TreasureHunt.io. Ali svaka promjena prolazi kroz ispravan proces — bez prečica.

## Instrukcije

Argument: `$ARGUMENTS`

Argument može biti:
- Prazan ili `full` — kompletan audit + improvement ciklus
- `security` — samo sigurnosni fixevi
- `performance` — samo performance optimizacije
- `ux` — samo UX/accessibility poboljšanja
- `tests` — samo proširenje test coverage-a
- `cleanup` — samo code quality i dead code

## Workflow

### Faza 1: Audit

Provedi audit koristeći kombinaciju:
- Čitanje koda (`app/`, `test/`, `db/`)
- `bin/rails test` — stanje test suite-a
- `bundle exec brakeman -q --no-pager` — security scan
- `bundle exec rubocop --format simple` — lint
- Konsultuj playbook (`.claude/docs/playbook/`) za uspostavljene pattern-e

Rezultat audita je lista konkretnih problema sa fajlom, linijom i opisom.

### Faza 2: Kategorizacija

Svaki pronađeni problem kategoriziraj kao:

| Kategorija | Primjeri | Treba PRD? | Treba ADR? |
|------------|----------|------------|------------|
| **Bug fix** | Broken method, crash, wrong return | NE | NE |
| **Security fix** | IDOR, XSS, session fixation, race condition | NE | NE |
| **Performance fix** | N+1, missing index, uncached query | NE | NE |
| **Test coverage** | Missing tests, edge cases | NE | NE |
| **Refactoring** | DRY, extract method, rename | NE | NE |
| **UX promjena** | Novi modal, promjena flow-a, nova komponenta | **DA** | NE |
| **Nova funkcionalnost** | Novi endpoint, novi feature, novo ponašanje | **DA** | Možda |
| **Arhitektonska promjena** | Nova library, promjena patterna, novi servis pattern | NE | **DA** |

### Faza 3: Spec gate

**Prije bilo kakve implementacije:**

1. **Ako ima stavki koje trebaju PRD:**
   - Grupiši ih u logičke feature-ove
   - Za svaku grupu kreiraj PRD (`/prd new [naslov]`)
   - Prikaži korisniku PRD na odobrenje
   - ZAUSTAVI SE i čekaj odobrenje
   - Tek nakon odobrenja nastavi na implementaciju

2. **Ako ima stavki koje trebaju ADR:**
   - Kreiraj ADR (`/adr new [naslov]`)
   - Prikaži korisniku na odobrenje
   - ZAUSTAVI SE i čekaj odobrenje

3. **Stavke bez PRD/ADR zahtjeva** (bug fix, security, performance, tests, refactoring):
   - Nastavi direktno na implementaciju
   - Ali i za ove — prikaži plan korisniku prije početka

### Faza 4: Implementacija

Za svaku stavku:

1. **Konsultuj playbook** — pročitaj relevantni segment iz `.claude/docs/playbook/`
2. **Implementiraj** — poštuj uspostavljene pattern-e
3. **Napiši testove** — svaki fix mora imati test koji dokazuje da radi
4. **Pokreni testove** — `bin/rails test` mora biti green nakon svake promjene
5. **Označi kao završeno** — koristi TaskUpdate

### Faza 5: Validacija

Nakon svih implementacija:

1. `bin/rails test` — svi testovi prolaze (unit + system)
2. `bundle exec brakeman -q --no-pager` — nema novih warnings
3. `bundle exec rubocop --format simple` — nema novih offenses
4. Ako postoje PRD-ovi — ažuriraj status na "Done"

### Faza 6: Dokumentacija

1. **Ingestuj nove pattern-e** — ako si uveo novi pattern, ažuriraj playbook
2. **Logiraj u log.md** — appenduj zapis o svemu što je urađeno:
   ```
   ## [YYYY-MM-DD] improvement-loop | [opis sesije]

   ### Kategorija: [security/performance/ux/tests/cleanup/full]

   ### Promjene bez PRD-a (bug/security/perf/refactor)
   - [Promjena 1]: fajl, opis
   - [Promjena 2]: fajl, opis

   ### Promjene sa PRD-om
   - PRD-XXXX: [naslov] — status: [Done/In Progress]

   ### Testovi
   - Prije: X testova, Y assertions
   - Poslije: X testova, Y assertions
   - Novi testovi: [lista]
   ```

## Pravila

1. **NIKAD ne implementiraj UX promjenu ili novi feature bez PRD-a** — čak ni "malu" promjenu
2. **NIKAD ne uvodi novu library ili mjenjaj pattern bez ADR-a**
3. **Bug fixevi, security, performance, testovi i refactoring NE trebaju PRD/ADR** — ali trebaju plan
4. **Svaka promjena mora imati test** — ne commituj fix bez testa
5. **Testovi moraju biti green prije prelaska na sljedeću stavku**
6. **Konsultuj playbook prije implementacije** — ne izmišljaj nove pattern-e
7. **Logiraj sve** — svaka sesija mora biti zapisana u log.md
8. **Prikaži plan korisniku** — čak i za "očigledne" fixeve, pokaži šta planiraš
9. **Ako si u dilemi da li nešto treba PRD — treba PRD**
10. **Ako korisnik kaže "radi autonomno"** — to znači "radi bez da pitaš za svaku sitnicu", NE "preskoči process"
