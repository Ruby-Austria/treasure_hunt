# Segment 5: Baza podataka

## Migracije

### Geografski podaci

Decimal sa visokom preciznošću za GPS koordinate (~11cm tačnost):

```ruby
add_column :locations, :lat, :decimal, precision: 10, scale: 7
add_column :locations, :long, :decimal, precision: 10, scale: 7
```

### Score/Procenat polja

```ruby
add_column :locations, :confidence_score, :decimal, precision: 3, scale: 2, default: 0.5
# Dozvoljava 0.00 - 9.99, ali validacija u modelu ograničava na 0..1
```

### Integer enum-i

```ruby
add_column :locations, :verification_state, :integer, default: 0
# 0 = ai_generated, 1 = auto_verified, 2 = human_verified
```

### JSONB za fleksibilne podatke

```ruby
add_column :locations, :metadata, :jsonb, default: {}
add_column :hunts, :generation_metadata, :jsonb, default: {}
```

Koristi JSONB (ne JSON) - podržava indeksiranje i upite.

### JSON nizovi

```ruby
add_column :clues, :hints, :json, default: []
add_column :adventures, :solved_clue_ids, :json, default: []
add_column :adventures, :revealed_hints, :json, default: []
```

## Indeksi

### Jednostavni indeksi

```ruby
add_index :locations, :verification_state
add_index :hunts, :status
```

### Kompozitni indeksi

```ruby
add_index :hunts, [:center_lat, :center_lng]
add_index :target_queues, [:city, :country], unique: true
```

### Parcijalni indeksi (conditional)

```ruby
add_index :locations, :google_place_id, unique: true, where: "google_place_id IS NOT NULL"
```

### Unique constraint na scope

```ruby
add_index :clues, [:hunt_id, :location_id], unique: true
add_index :clues, [:hunt_id, :sequence_number], unique: true
```

## Konvencije

1. **Foreign key-evi** su uvijek indeksirani (Rails default)
2. **Unique constraint** na bazi, ne samo u validaciji
3. **Default vrijednosti** za JSON/JSONB polja: `default: {}` ili `default: []`
4. **Parcijalni indeksi** za nullable unique polja
5. **Boolean polja** uvijek sa `default: false`
6. **Temporal polja** za praćenje akcija: `last_generated_at`, `last_hint_revealed_at`
7. **Counter polja** sa `default: 0`: `usage_count`, `hints_used`

---

## Povezani segmenti

- [01-modeli](01-modeli.md) - Modeli koji koriste ova polja (enum-i, validacije nad tipovima)
- [02-servisi](02-servisi.md) - DistanceCalculator koristi GPS precision za Haversine formula
