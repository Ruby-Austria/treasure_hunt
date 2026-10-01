# Ingest - Unos novog znanja u Knowledge Base

Kada se nauči nešto novo (pattern, library, bugfix insight, arhitekturalna spoznaja), formalno ga unesi u wiki.

## Instrukcije

Argument: `$ARGUMENTS`

Argument može biti:
- URL članka/dokumentacije
- Opis naučenog pattern-a ili spoznaje
- Referenca na kod koji je upravo implementiran
- "codebase" - automatski skeniraj codebase za nove pattern-e koji nisu u playbook-u

### Workflow

1. **Razumij izvor**
   - Ako je URL: dohvati i pročitaj sadržaj
   - Ako je opis: razumij šta je novo znanje
   - Ako je "codebase": uporedi trenutni kod sa playbook segmentima i identificiraj razlike
   - Diskutuj sa korisnikom: šta je ključno? Šta je novo u odnosu na postojeće znanje?

2. **Identificiraj ciljne stranice**
   - Pročitaj `.claude/docs/index.md` za pregled postojećih stranica
   - Odredi koje playbook segmente treba ažurirati
   - Odredi da li treba kreirati novu stranicu (analiza, novi segment)
   - Odredi da li novo znanje zahtijeva ADR (ako je arhitektonska odluka)

3. **Integriši znanje**
   - Ažuriraj relevantne playbook segmente sa novim pattern-ima
   - Dodaj cross-reference-e prema drugim segmentima
   - Ako kreira novu stranicu, dodaj je u index.md
   - Provjeri da novo znanje ne kontradiči postojeće - ako da, razriješi kontradikciju

4. **Ažuriraj infrastrukturu**
   - Ažuriraj `.claude/docs/index.md` (novi unosi, ažurirani opisi, ključne riječi)
   - Appenduj entry u `.claude/docs/log.md` sa formatom:
     ```
     ## [YYYY-MM-DD] ingest | Kratak naslov
     - Izvor: [URL ili opis]
     - Ključne spoznaje: [bullet lista]
     - Stranice kreirane: [lista]
     - Stranice ažurirane: [lista]
     ```

5. **Izvijesti korisnika**
   - Prikaži šta je naučeno i gdje je uneseno
   - Predloži follow-up akcije (npr. "možda bi trebalo kreirati ADR za ovu odluku")

## Tipovi znanja za ingest

| Tip | Primjer | Ciljni segment |
|-----|---------|----------------|
| Novi Rails pattern | "Discovered query object pattern" | playbook/02-servisi ili novi segment |
| Nova library | "Added Flipper for feature flags" | playbook relevantni + možda ADR |
| Bug fix insight | "Race condition fix via pessimistic locking" | playbook/05-baza ili playbook/02-servisi |
| Eksterni članak | URL sa best practice-om | Relevantni playbook segmenti |
| Codebase scan | "codebase" | Svi segmenti koji su outdated |
| Arhitekturalna odluka | "Switching from X to Y" | ADR + playbook |

## Pravila

- **Nikad ne briši postojeće znanje** bez eksplicitnog razloga - radije ažuriraj ili označi kao deprecated
- **Cross-referenciraj** - svako novo znanje treba biti povezano sa postojećim
- **Budi koncizan** - playbook segmenti dokumentuju pattern-e, ne tutoriale
- **Validiraj prema kodu** - prije ingesta provjeri da pattern zaista postoji u codebase-u
- **Log je obavezan** - svaki ingest MORA biti zabilježen u log.md
