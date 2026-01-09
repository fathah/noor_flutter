# Noor Flutter Package – Full Architecture & Design

## Purpose

`noor` is a Flutter/Dart package that provides **authoritative Islamic data** such as Prayer Times and Hijri information in a **deterministic, offline-first, region-aware** manner.

This package is **not a UI library** and **not a simple calculator**.
It is a **data orchestration SDK** that ensures correctness across regions, madhabs, and local practices.

---

## Core Principles

1. **Local DB is the Source of Truth**

   * All reads come from local storage
   * API and offline calculations only *populate* the DB

2. **Region-aware, Not Purely Mathematical**

   * Backend provides authoritative data where calculations fail
   * Offline calculation is only a fallback

3. **Rolling Cache (No History Hoarding)**

   * Only current active location is stored
   * Only current month + next month are cached
   * When location changes → prayer DB is reset

4. **Deterministic Outputs**

   * Same input → same output
   * No repeated recalculations

5. **24-hour Canonical Storage**

   * All times stored as `HH:mm`
   * 12-hour format only via extensions

---

## High-Level Modules

```
noor
 ├─ core        → initialization, config, errors
 ├─ network     → shared HTTP client
 ├─ storage     → local persistence abstraction
 ├─ location    → country/state/district/region handling
 ├─ prayer      → prayer times logic
 ├─ hijri       → (future)
 └─ utils       → helpers & extensions
```

---

## Storage Design (ONLY 2 BOXES)

### Box 1: `noor_meta`

Stores **identity, configuration, adjustments, and cached lists**.

**Stored Data:**

* countryId
* stateId
* districtId
* regionId
* latitude / longitude
* timezone
* calculation method
* madhab
* prayer time adjustments
* cached states/districts/regions lists

**Example Keys:**

```
location.countryId
location.regionId
settings.calcMethod
adjustments.prayer
states-IN
```

---

### Box 2: `noor_prayer_times` (SOURCE OF TRUTH)

Stores prayer times keyed by **day-month only**.

**Key Format:**

```
"<day>-<month>"
```

**Value Format (24h strings):**

```
{
  day: 9,
  month: 1,
  fajr: "05:12",
  sunrise: "06:32",
  dhuhr: "12:18",
  asr: "15:41",
  maghrib: "18:05",
  isha: "19:25"
}
```

> Year is intentionally ignored. Backend guarantees correctness.

---

## Authority Chain (Locked)

```
User Adjustments
   ↑
Local DB (Hive)
   ↑
Backend API
   ↑
Offline Calculation (adhan.dart)
```

---

## Location Hierarchy

```
Country
 └─ State
    └─ District / Zone
       └─ Region (final authority)
```

Resolution order when fetching prayer times:

1. regionId
2. districtId
3. stateId
4. countryId
5. latitude + longitude

---

## Network Layer (Shared for All APIs)

### Purpose

A single reusable HTTP client for all future Noor APIs:

* Prayer Times
* Hijri
* Tafsir
* Events

### Responsibilities

* Base URL handling
* Headers
* Error normalization
* JSON parsing

### Example

```
NoorHttpClient.get("/times?..." )
```

No API keys for now. Designed for future injection.

---

## Prayer Module

### Responsibilities

* Sync prayer times (API / offline)
* Cache monthly data
* Provide runtime helpers

### Monthly Sync Rules

* Fetch **current month + next month** only
* If both exist → skip fetch
* If missing → fetch only missing months

### Offline Fallback

* Uses `adhan_dart`
* Calculated data is stored in DB
* Treated same as API data

---

## Location Change Rule (Critical)

When ANY of the following change:

* countryId
* stateId
* districtId
* regionId
* latitude / longitude
* timezone
* calculation method
* madhab

➡️ `noor_prayer_times` is **cleared immediately**
➡️ Fresh monthly sync is triggered

---

## Public API (Conceptual)

```
await Noor.initialize();

await Noor.setCountryId(91);
await Noor.setStateId(32);
await Noor.setDistrictId(332);
await Noor.setRegionId(4582);

await Noor.setCoordinates(lat: 11.25, lng: 75.78);

final today = Noor.prayer.today();
final next = Noor.prayer.next();
```

---

## Adjustments

* Stored in `noor_meta`
* Applied AFTER DB read
* Never mutate stored times

Example:

```
{ fajr: -2, isha: +1 }
```

---

## Time Utilities

### Default

* All stored times are `HH:mm`

### Extensions

* `to12h()` → `6:05 PM`
* `toDateTime()` → runtime conversion

---

## Error Philosophy

* Never crash
* Return last valid data
* Silent fallback
* Debug logging only in dev mode

---

## Future Modules (Planned)

* Hijri Date (calculated + regional override)
* Moon sighting
* Tafsir APIs
* Islamic events calendar
* Mosque iqama times

---

## Summary

`noor` is a **religious data engine**, not a calculator.
It guarantees correctness, offline support, and regional authenticity.

This architecture is final and stable. Any implementation must follow these rules strictly.
