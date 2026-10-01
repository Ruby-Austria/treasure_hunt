# TreasureHunt.io - Claude Code konfiguracija

## Projekat

AI-generisana platforma za lokacijski bazirane treasure hunt igre. Rails 8.1.3 + PostgreSQL + Hotwire + Tailwind.

## Knowledge Base

Ovaj projekat održava persistent knowledge base u `.claude/docs/`. Znanje se akumulira - svaki ingest, svaka implementacija, svaki query obogaćuje bazu. LLM piše i održava wiki, čovjek usmjerava i kuriра izvore.

### Struktura

```
.claude/docs/
├── index.md          # Unified katalog svih stranica - ČITAJ OVO PRVO
├── log.md            # Hronološki log aktivnosti (append-only)
├── decisions.md      # Komprimirani ADR/PRD zapisi (šta je odlučeno i zašto)
└── playbook/         # Trajno znanje: kako se gradi (8 segmenata)
```

### Navigacija

Kada tražiš informaciju, počni od `index.md`. Index sadrži sve stranice sa ključnim riječima. Pronađi relevantne stranice i čitaj ih. Ako odgovor zahtijeva sintezu više stranica - to je znak da trebaš kreirati novu stranicu (analizu).

### Tri operacije

**Ingest** (`/ingest`) - Unos novog znanja. Kada se nauči nešto novo (pattern, library, bugfix, članak), ne ostavljaj to u chat historiji. Formalno ga integriši u wiki - ažuriraj playbook segmente, dodaj cross-reference, logiraj u log.md.

**Query-as-artifact** - Korisne analize koje nastanu tokom razgovora zaslužuju trajno čuvanje. Ako pitanje zahtijeva sintezu više stranica, rezultat filovati nazad kao novu stranicu u wiki. Ne sve - samo ono što ima trajnu vrijednost.

**Lint** (`/lint`) - Periodična zdravstvena provjera. Da li playbook odražava stvarni kod? Ima li kontradikcija? Orphan stranica? Missing cross-reference-a? Pokreni na kraju značajne sesije ili prije nove implementacije.

## Decisions

Sve prošle arhitektonske i product odluke su komprimirane u `.claude/docs/decisions.md`. Konsultuj taj fajl za kontekst o tome šta je građeno i zašto.

## Komande

| Komanda | Namjena |
|---------|---------|
| `/improve` | **Autonomni improvement loop** — audit, kategorizacija, spec gate, implementacija, validacija |
| `/playbook` | Referenca za implementacijske pattern-e (po segmentima) |
| `/ingest` | Unos novog znanja u knowledge base |
| `/lint` | Zdravstvena provjera dokumentacije |
| `/tech-review` | Tehnički review koda |
| `/product-review` | Product review feature-a |
| `/qa-review` | QA review implementacije |
| `/user-feedback` | UX feedback |
| `/repo-review` | Kompletna revizija repozitorija (Tech Lead + PM perspektiva) |

## Tech Stack (ne mijenjaj bez ADR-a)

- **Backend:** Rails 8.1.3, PostgreSQL, Solid Stack (Queue, Cache, Cable)
- **Frontend:** Hotwire (Turbo + Stimulus), Tailwind CSS + DaisyUI
- **Deploy:** Docker + Kamal
- **CI/CD:** GitHub Actions

## Playbook

Trajno znanje o tome kako se gradi funkcionalnost u ovom projektu živi u `.claude/docs/playbook/`.
9 segmenata: modeli, servisi, kontroleri, views/stimulus, baza, AI integracija, eksterni API-ji, testiranje, rute/auth.
Svi segmenti su međusobno cross-referencirani.

**Prije implementacije**: konsultuj relevantni playbook segment (`/playbook [segment]`) da slijediš uspostavljene pattern-e.
**Nakon uvođenja novog pattern-a**: ingestuj ga (`/ingest [opis]`) da wiki ostane ažuran.

## Ponašanje

### Autonomni rad

Kada korisnik kaže "radi autonomno" ili "improvement loop" — **uvijek koristi `/improve`**. Nikad ne preskoči spec gate. "Autonomno" znači "bez pitanja za svaku sitnicu", ne "bez procesa".

### Kada automatski ingestovati

- Nakon implementacije novog feature-a koji uvodi novi pattern
- Kada se doda nova library ili promijeni tech stack
- Kada se otkrije bugfix koji otkriva nepoznat edge case
- Kada korisnik podijeli eksternu referencu koja mijenja pristup

### Kada automatski lintati

- Na kraju značajne implementacijske sesije
- Prije početka implementacije feature-a - lint relevantne segmente
- Kada korisnik pita "da li je dokumentacija ažurna"

### Log discipline

Svaka značajna operacija se logira u `.claude/docs/log.md`:
- Ingest: šta je naučeno, koje stranice su ažurirane
- Implementacija: koji PRD, koji zahtjevi su zadovoljeni
- Lint: zdravlje wiki-ja, problemi pronađeni
- ADR/PRD: kreiranje i promjene statusa

## Konvencije

- Rails konvencije i Rails Way
- Thin controllers, logika u services/models
- Service objects za kompleksne operacije
- Rubocop za linting
- Testovi prije commitanja
- Commit poruke na engleskom, komunikacija na jeziku korisnika
