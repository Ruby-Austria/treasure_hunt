# PRD Management

Ti upravljaš Product Requirement Documents za TreasureHunt.io.

## Instrukcije

Argument: `$ARGUMENTS`

Parsiraj argument da odrediš akciju:

### Akcija: `list` (ili prazan argument)
Pročitaj `.claude/docs/prds/INDEX.md` i prikaži listu svih PRD-ova sa statusom.

### Akcija: `new [naslov]`
1. Pročitaj `.claude/docs/prds/INDEX.md` da odrediš sljedeći broj (XXXX)
2. Pročitaj `.claude/docs/prds/TEMPLATE.md` za strukturu
3. Vodi strukturiranu diskusiju sa korisnikom:
   - Koji problem rješavamo?
   - Ko su korisnici?
   - Koji su ciljevi i ne-ciljevi?
   - Koje su korisničke priče?
   - Koji su funkcionalni zahtjevi i prihvatni kriteriji?
   - Postoje li nefunkcionalni zahtjevi?
4. Kreiraj PRD fajl: `.claude/docs/prds/XXXX-slug-naslov.md`
5. Ažuriraj `.claude/docs/prds/INDEX.md`
6. Prikaži kreirani PRD korisniku za review
7. Predloži koje ADR-ove bi trebalo kreirati na osnovu tehničkih odluka u PRD-u

### Akcija: `update [XXXX]`
1. Pročitaj navedeni PRD fajl
2. Diskutuj promjene sa korisnikom
3. Ažuriraj PRD fajl i changelog sekciju
4. Ako se status mijenja, ažuriraj i INDEX.md

### Akcija: `show [XXXX]`
Pročitaj i prikaži navedeni PRD.

### Akcija: `approve [XXXX]`
1. Pročitaj PRD i provjeri da su svi zahtjevi definirani
2. Postavi status na "Approved"
3. Ažuriraj INDEX.md
4. Predloži sljedeće korake (implementacija, potrebne ADR-ove)

## Pravila

- Svaka PRD ima jedinstveni broj, sekvencijalno dodijeljen
- PRD MORA biti u statusu "Approved" prije početka implementacije
- Ne-ciljevi su jednako važni kao ciljevi - eksplicitno navedi šta feature NE pokriva
- Svaki funkcionalni zahtjev MORA imati prihvatne kriterije
- Piši na jeziku na kojem korisnik komunicira
- Linkuj relevantne ADR-ove u PRD-u
