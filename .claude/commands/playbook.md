# Playbook - Referenca za implementacijske pattern-e

Prikaži relevantne implementacijske pattern-e iz projekta.

## Instrukcije

Argument: `$ARGUMENTS`

### Akcija: prazan argument ili `list`
Pročitaj `.claude/docs/playbook/INDEX.md` i prikaži listu svih segmenata.

### Akcija: broj ili naziv segmenta (npr. `2`, `servisi`, `ai`)
1. Pronađi odgovarajući segment iz INDEX.md
2. Pročitaj cijeli fajl tog segmenta
3. Prikaži sadržaj korisniku

### Akcija: `all`
Pročitaj INDEX.md i ukratko prikaži ključne pattern-e iz svakog segmenta (ne cijeli sadržaj, samo sažetak).

### Akcija: `update [segment]`
1. Pročitaj trenutni segment fajl
2. Provjeri stvarni kod u codebase-u da vidiš da li su pattern-i ažurni
3. Ažuriraj segment sa eventualnim novim pattern-ima
4. Izvijesti korisnika o promjenama

## Napomena

Playbook dokumentuje **kako se stvari rade u ovom projektu** - trajno znanje o pattern-ima i konvencijama.
Ne dokumentuje šta treba napraviti (to je PRD) niti zašto je nešto odlučeno (to je ADR).

Kada implementiraš novu funkcionalnost, UVIJEK konsultuj relevantni playbook segment da slijediš uspostavljene pattern-e.
