# Feature Pipeline — Od ideje do produkcije

Ti vodiš feature kroz kompletni spec-driven proces. Korisnik daje ideju, ti je razradiš, specificiraš, implementiraš i verificiraš.

## Instrukcije

Argument: `$ARGUMENTS`

Argument je opis feature-a ili promjene koju korisnik želi. Može biti:
- Kratka ideja: `leaderboard na home stranici`
- Detaljan zahtjev: `dark mode za adventure ekran sa auto-detect sistema`
- Referenca na postojeći PRD: `PRD-0003` (nastavlja rad na postojećem)

## Workflow

### Faza 1: Razumijevanje

Razumi šta korisnik želi. Ako je opis nejasan ili nepotpun:
1. Pogledaj trenutno stanje relevantnog koda i UI-a
2. Postavi **fokusirana pitanja** — ne više od 3-4, ne anketu
3. Predloži scope na osnovu onoga što vidiš

Cilj: imati dovoljno konteksta da napišeš PRD. Ne tražiš savršenstvo — PRD se može revidirati.

### Faza 2: PRD

1. Pročitaj `.claude/docs/prds/INDEX.md` za sljedeći broj
2. Pročitaj `.claude/docs/prds/TEMPLATE.md` za strukturu
3. **Napiši PRD** na osnovu razgovora:
   - Problem, korisnici, ciljevi, ne-ciljevi
   - Korisničke priče
   - Funkcionalni zahtjevi sa prihvatnim kriterijima
   - Nefunkcionalni zahtjevi
4. Kreiraj fajl: `.claude/docs/prds/XXXX-slug.md`
5. Ažuriraj INDEX.md
6. **Prikaži PRD korisniku** — čekaj feedback i odobrenje

**STOP** — ne nastavljaj bez odobrenja PRD-a.

### Faza 3: ADR (ako treba)

Procijeni da li feature zahtijeva ADR. Treba ADR ako:
- Uvodiš novu library ili servis
- Mijenjaš arhitektonski pattern
- Donosiš odluku o infrastrukturi
- Trade-off koji utiče na performanse, sigurnost ili skalabilnost
- Novi data model koji utiče na više dijelova sistema

Ako treba:
1. Kreiraj ADR prema `.claude/docs/adrs/TEMPLATE.md`
2. Prikaži korisniku na odobrenje
3. **STOP** — čekaj odobrenje

Ako ne treba — nastavi.

### Faza 4: Implementacija

1. Postavi PRD status na "In Progress"
2. **Konsultuj playbook** — pročitaj relevantne segmente iz `.claude/docs/playbook/`
3. Kreiraj plan implementacije:
   - Lista taskova iz funkcionalnih zahtjeva
   - Zavisnosti i redoslijed
   - Prikaži plan korisniku
4. Za svaki zahtjev:
   - Implementiraj prema prihvatnim kriterijima
   - Napiši testove
   - Pokreni `bin/rails test` — mora biti green
   - Označi kao završeno
5. Poštuj tehničke odluke iz ADR-ova

### Faza 5: Verifikacija

1. **Testovi**: `bin/rails test` — svi prolaze
2. **Lint**: `bundle exec rubocop --format simple` — nema novih offenses
3. **Security**: `bundle exec brakeman -q --no-pager` — nema novih warnings
4. **Browser test** (ako je UI promjena):
   - Otvori stranicu u browseru
   - Provjeri golden path
   - Provjeri edge case-ove
   - Provjeri mobile responsiveness
5. Prođi kroz SVE prihvatne kriterije iz PRD-a — svaki mora biti zadovoljen

### Faza 6: Završetak

1. Ažuriraj PRD status na "Done"
2. Ažuriraj PRD changelog
3. Appenduj u `.claude/docs/log.md`:
   ```
   ## [YYYY-MM-DD] feat | [naziv feature-a]

   ### PRD: PRD-XXXX — [naslov]
   ### ADR: ADR-XXXX — [naslov] (ako postoji)

   ### Implementirano
   - FR-1: [opis] — Done
   - FR-2: [opis] — Done

   ### Testovi
   - Prije: X testova, Y assertions
   - Poslije: X testova, Y assertions
   - Novi testovi: [lista]

   ### Fajlovi
   - [lista izmijenjenih/kreiranih fajlova]
   ```
4. Ako si uveo novi pattern — ažuriraj playbook (`/ingest`)

## Pravila

1. **Svaki feature prolazi kroz PRD** — bez izuzetaka
2. **PRD mora biti odobren prije implementacije** — ne preskači
3. **ADR za arhitektonske odluke** — ako si u dilemi, napravi ADR
4. **Playbook prije koda** — konsultuj postojeće pattern-e
5. **Testovi za svaki zahtjev** — prihvatni kriteriji = test scenariji
6. **Green suite prije prelaska** — ne gomilaj broken testove
7. **Browser verifikacija za UI** — type checking nije feature testing
8. **Ne dodaji ono što nije u PRD-u** — scope creep je neprijatelj
9. **Logiraj sve** — svaka sesija mora biti u log.md
10. **Ako otkriješ da PRD nije kompletan** — stani, ažuriraj PRD, traži re-odobrenje
