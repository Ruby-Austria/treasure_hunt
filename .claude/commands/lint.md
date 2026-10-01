# Lint - Zdravstvena provjera Knowledge Base-a

Periodična provjera konzistentnosti, tačnosti i kompletnosti wiki-ja.

## Instrukcije

Argument: `$ARGUMENTS`

Argument može biti:
- Prazan ili `all` - kompletna provjera svega
- `playbook` - samo playbook segmenti
- `adrs` - samo ADR-ovi
- `prds` - samo PRD-ovi
- `index` - samo index i cross-reference konzistentnost
- Broj segmenta (npr. `2`) - samo taj playbook segment

### Workflow

1. **Pročitaj index.md** za pregled svih stranica

2. **Provjeri svaku kategoriju:**

#### Playbook provjere
Za svaki segment:
- [ ] **Tačnost**: Pročitaj stvarni kod u codebase-u i uporedi sa dokumentovanim pattern-ima. Da li se pattern-i poklapaju?
- [ ] **Kompletnost**: Postoje li pattern-i u kodu koji nisu dokumentovani?
- [ ] **Zastarjelost**: Da li su neki pattern-i deprecated ili zamijenjeni novim?
- [ ] **Cross-reference**: Da li svaki segment linkuje relevantne druge segmente?
- [ ] **Kontradikcije**: Da li dva segmenta dokumentuju isti pattern na različit/konfliktni način?

#### ADR provjere
- [ ] **Status konzistentnost**: Da li ADR-ovi sa statusom "Accepted" i dalje odražavaju stvarno stanje?
- [ ] **Implementacija**: Da li su odluke iz Accepted ADR-ova zaista implementirane?
- [ ] **Missing ADR-ovi**: Postoje li značajne tehničke odluke u kodu bez pripadajućeg ADR-a?

#### PRD provjere
- [ ] **Status konzistentnost**: Da li su PRD-ovi sa statusom "In Progress" zaista u toku?
- [ ] **Completeness**: Da li "Done" PRD-ovi imaju sve prihvatne kriterije zadovoljene?
- [ ] **Orphan PRD-ovi**: Da li postoje PRD-ovi koji su zastarjeli ili napušteni?

#### Index provjere
- [ ] **Completeness**: Da li su sve stranice u wiki-ju navedene u index.md?
- [ ] **Dead links**: Da li svi linkovi u index.md pokazuju na postojeće fajlove?
- [ ] **Ključne riječi**: Da li su ključne riječi tačne i dovoljne za pretragu?

#### Strukturalne provjere
- [ ] **Orphan stranice**: Stranice koje niko ne linkuje
- [ ] **Missing stranice**: Koncepti koji se spominju ali nemaju svoju stranicu
- [ ] **Praznine u znanju**: Oblasti koje bi trebale biti dokumentovane ali nisu

3. **Generiši izvještaj**

```
## Lint Report - [YYYY-MM-DD]

### Zdravlje: [HEALTHY | NEEDS_ATTENTION | STALE]

### Problemi pronađeni
#### Critical (tačnost)
- [Pattern X u segmentu Y ne odgovara kodu - linija Z]

#### Major (kompletnost)
- [Novi pattern X u codebase-u nije dokumentovan]

#### Minor (stil/linkovi)
- [Segment X nema cross-reference na segment Y]

### Preporuke
- [ ] Akcija 1
- [ ] Akcija 2

### Statistike
- Stranica ukupno: N
- Stranica provjereno: N
- Problema pronađeno: N
- Posljednji lint: [datum]
```

4. **Ažuriraj infrastrukturu**
   - Appenduj entry u `.claude/docs/log.md`:
     ```
     ## [YYYY-MM-DD] lint | Health check
     - Scope: [all/playbook/adrs/...]
     - Zdravlje: [HEALTHY/NEEDS_ATTENTION/STALE]
     - Problema pronađeno: N (X critical, Y major, Z minor)
     - Automatski ispravljeno: N
     ```

5. **Automatski ispravi trivijalne probleme**
   - Broken linkovi u index.md
   - Missing cross-reference-i
   - Ažuriranje ključnih riječi

6. **Predloži akcije za netrivijalne probleme**
   - Za critical probleme: predloži `/ingest codebase` za ažuriranje
   - Za missing ADR-ove: predloži `/adr new`
   - Za orphan stranice: predloži brisanje ili linkovanje

## Kada lintati?

- **Automatski**: Na kraju svake značajne implementacijske sesije
- **Periodično**: Jednom sedmično na cjelokupnom wiki-ju
- **Ciljano**: Prije implementacije feature-a - lint relevantne segmente da osiguraš da su ažurni
