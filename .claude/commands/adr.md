# ADR Management

Ti upravljaš Architecture Decision Records za TreasureHunt.io.

## Instrukcije

Argument: `$ARGUMENTS`

Parsiraj argument da odrediš akciju:

### Akcija: `list` (ili prazan argument)
Pročitaj `.claude/docs/adrs/INDEX.md` i prikaži listu svih ADR-ova sa statusom.

### Akcija: `new [naslov]`
1. Pročitaj `.claude/docs/adrs/INDEX.md` da odrediš sljedeći broj (XXXX)
2. Pročitaj `.claude/docs/adrs/TEMPLATE.md` za strukturu
3. Diskutuj sa korisnikom o kontekstu i odluci - postavljaj pitanja dok ne razumiješ problem dovoljno dobro
4. Kreiraj novi ADR fajl: `.claude/docs/adrs/XXXX-slug-naslov.md`
5. Ažuriraj `.claude/docs/adrs/INDEX.md` sa novim unosom
6. Prikaži kreirani ADR korisniku za review

### Akcija: `update [XXXX]`
1. Pročitaj navedeni ADR fajl
2. Diskutuj promjene sa korisnikom
3. Ažuriraj ADR fajl
4. Ako se status mijenja, ažuriraj i INDEX.md

### Akcija: `show [XXXX]`
Pročitaj i prikaži navedeni ADR.

## Pravila

- Svaka ADR ima jedinstveni broj, sekvencijalno dodijeljen
- Slug u imenu fajla je kebab-case verzija naslova
- Nikad ne briši ADR - umjesto toga, postavi status na Deprecated ili Superseded
- Datum je uvijek u ISO formatu (YYYY-MM-DD)
- Piši na jeziku na kojem korisnik komunicira
- ADR-ovi se kreiraju za ZNAČAJNE tehničke odluke, ne za trivijalne promjene
