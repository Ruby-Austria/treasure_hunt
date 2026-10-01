# Spec-Driven Implementation

Implementiraj feature prema odobrenoj specifikaciji.

## Instrukcije

Argument: `$ARGUMENTS`

Argument je referenca na PRD (npr. `0001` ili `naziv`) i opciono specifični zahtjev (npr. `FR-1`).

### Workflow

1. **Učitaj specifikaciju**
   - Pročitaj navedeni PRD iz `.claude/docs/prds/`
   - Pročitaj sve povezane ADR-ove navedene u PRD-u
   - Provjeri da je PRD status "Approved" - ako nije, obavijesti korisnika i zaustavi se

2. **Napravi plan implementacije**
   - Kreiraj listu taskova na osnovu funkcionalnih zahtjeva iz PRD-a
   - Identificiraj zavisnosti između zahtjeva
   - Predloži redoslijed implementacije
   - Provjeri nefunkcionalne zahtjeve koji utiču na implementaciju
   - Prikaži plan korisniku i traži potvrdu prije početka

3. **Implementiraj**
   - Radi prema odobrenom planu
   - Za svaki funkcionalni zahtjev:
     - Implementiraj prema opisu i prihvatnim kriterijima
     - Napiši testove koji pokrivaju prihvatne kriterije
     - Označi zahtjev kao završen
   - Poštuj tehničke odluke iz povezanih ADR-ova
   - Poštuj tech stack definisan u `.claude/commands/tech-review.md`

4. **Validacija**
   - Prođi kroz sve prihvatne kriterije iz PRD-a
   - Pokreni testove
   - Pozovi `/tech-review` za code review
   - Pozovi `/qa-review` za QA provjeru

5. **Završetak**
   - Ažuriraj PRD status na "In Progress" kada počneš, "Done" kada završiš
   - Ažuriraj PRD changelog sa implementiranim zahtjevima
   - Pripremi summary implementacije za korisnika

## Pravila

- NIKAD ne implementiraj feature bez odobrene specifikacije
- Ako tokom implementacije otkriješ da specifikacija nije kompletna, zaustavi se i ažuriraj PRD
- Ako trebaš donijeti novu tehničku odluku koja nije pokrivena ADR-om, kreiraj novi ADR
- Prihvatni kriteriji iz PRD-a su tvoji acceptance testovi
- Ne dodaji funkcionalnost koja nije u specifikaciji
