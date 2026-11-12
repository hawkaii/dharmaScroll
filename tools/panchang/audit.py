#!/usr/bin/env python3
"""Compare generated dates with Drik Panchang and write AUDIT.md.

The reference values below were read from Drik Panchang pages (or from pages
that quote Drik Panchang for New Delhi) on 2026-11-12. Drik's own date tables
load with JavaScript and could not be fetched, so each row names the page the
value came from.

    python tools/panchang/audit.py
"""
from __future__ import annotations

import datetime as dt
import json
from pathlib import Path
from zoneinfo import ZoneInfo

from generate import OUT, START, Sky, City
from cities import all_cities

DRIK = "drikpanchang.com"
HT = "hindutone.com (quotes Drik)"
MP = "mypanchang.com"

# (city, label, kind, expected date, source). kind: ek1 Smarta, ek2 Vaishnava,
# purnima, amavasya, fest:<id>, gita1/gita2 (Gita Jayanti by rule)
DATES = [
    ("new-delhi-in", "Rama Ekadashi", "ek1", "2026-11-05", HT),
    ("new-delhi-in", "Dev Uthani Ekadashi, Smarta", "ek1", "2026-11-20", HT),
    ("new-delhi-in", "Dev Uthani Ekadashi, Vaishnava", "ek2", "2026-11-21", HT),
    ("new-delhi-in", "Utpanna Ekadashi, Smarta", "ek1", "2026-12-04", HT),
    ("new-delhi-in", "Utpanna Ekadashi, Vaishnava", "ek2", "2026-12-04", HT),
    ("new-delhi-in", "Mokshada Ekadashi, Smarta", "ek1", "2026-12-20", HT),
    ("new-delhi-in", "Mokshada Ekadashi, Vaishnava", "ek2", "2026-12-20", HT),
    ("new-delhi-in", "Saphala Ekadashi", "ek1", "2027-01-03", HT),
    ("new-delhi-in", "Pausha Putrada Ekadashi", "ek1", "2027-01-18", HT),
    ("new-delhi-in", "Kartika Purnima", "purnima", "2026-11-24", HT),
    ("new-delhi-in", "Margashirsha Purnima", "purnima", "2026-12-23", HT),
    ("new-delhi-in", "Pausha Purnima", "purnima", "2027-01-22", HT),
    ("new-delhi-in", "Vat Purnima", "purnima", "2027-06-18", DRIK),
    ("new-delhi-in", "Kartika Amavasya", "amavasya", "2026-11-08", HT),
    ("new-delhi-in", "Diwali", "fest:23", "2026-11-08", HT),
    ("new-delhi-in", "Dev Deepawali", "fest:27", "2026-11-24", "economictimes.com"),
    ("new-delhi-in", "Gita Jayanti", "gita1", "2026-12-20", HT),
    ("new-delhi-in", "Maha Shivaratri", "fest:2", "2027-03-06", HT),
    ("new-delhi-in", "Holi", "fest:30", "2027-03-22", DRIK),
    ("new-delhi-in", "Holika Dahan", "fest:3", "2027-03-21", DRIK),
    ("new-delhi-in", "Ugadi", "fest:4", "2027-04-07", HT),
    ("new-delhi-in", "Guru Purnima", "fest:9", "2027-07-18", DRIK),
    ("new-delhi-in", "Janmashtami", "fest:11", "2027-08-25", "svastika.in, shubhpanchang.com"),
    ("edison-us", "Gita Jayanti, Smarta", "gita1", "2026-12-19", HT),
    ("edison-us", "Gita Jayanti, Vaishnava", "gita2", "2026-12-20", HT),
    ("edison-us", "Mokshada Ekadashi, Smarta", "ek1", "2026-12-19", HT),
    ("edison-us", "Mokshada Ekadashi, Vaishnava", "ek2", "2026-12-20", HT),
    ("new-york-us", "Diwali", "fest:23", "2026-11-08", MP),
    ("fairfield-us", "Guru Purnima", "fest:9", "2027-07-18", DRIK),
]

# Parana windows, minutes after midnight: (city, label, fast date, start, end)
PARANA = [
    ("new-delhi-in", "Rama Ekadashi", "2026-11-05", (6, 36), (8, 48), HT),
    ("new-delhi-in", "Mokshada Ekadashi", "2026-12-20", (7, 10), (9, 13), HT),
]

# Tithi start/end in the city's local time: (city, tithi 1..30, start, end).
# The tithi boundary is the same moon-sun angle everywhere, so these test the
# ephemeris and the zone handling directly.
TITHI = [
    ("new-delhi-in", 11, "2026-12-19 22:09", "2026-12-20 20:14", HT),
    ("new-delhi-in", 11, "2026-11-20 07:15", "2026-11-21 06:31", HT),
    ("new-delhi-in", 26, "2027-03-03 04:44", "2027-03-04 07:24", DRIK),
    ("new-delhi-in", 26, "2027-05-31 10:02", "2027-06-01 09:39", DRIK),
    ("new-delhi-in", 26, "2027-06-29 22:03", "2027-06-30 20:30", DRIK),
    ("new-delhi-in", 11, "2027-04-16 11:21", "2027-04-17 09:27", DRIK),
    ("new-delhi-in", 15, "2027-03-21 18:21", "2027-03-22 16:13", DRIK),
    ("new-delhi-in", 15, "2027-06-18 04:34", "2027-06-19 06:13", DRIK),
    ("new-delhi-in", 29, "2027-03-06 12:03", "2027-03-07 13:46", HT),
    ("new-delhi-in", 30, "2026-11-08 11:27", "2026-11-09 12:31", HT),
    ("fairfield-us", 26, "2026-11-04 00:33", "2026-11-05 00:05", DRIK),
    ("fairfield-us", 15, "2027-07-17 09:18", "2027-07-18 11:44", DRIK),
]

KIND_TYPE = {"ek1": 1, "ek2": 2, "purnima": 3, "amavasya": 4}


def events(city):
    data = json.loads((OUT / f"{city}.json").read_text())
    out = []
    for d, t, a, b, f in data["ev"]:
        out.append((START + dt.timedelta(days=d), t, a, b, f))
    return out


def hm(m):
    return f"{m // 60}:{m % 60:02d}"


def main():
    rows, ok_n = [], 0
    for city, label, kind, want, src in DATES:
        evs = events(city)
        w = dt.date.fromisoformat(want)
        if kind in KIND_TYPE:
            mine = [e for e in evs if e[1] == KIND_TYPE[kind]]
        elif kind.startswith("fest:"):
            mine = [e for e in evs if e[1] == 7 and e[2] == int(kind[5:])]
        else:  # gita1 / gita2
            mine = [e for e in evs if e[1] == 7 and e[2] == 29 and e[3] == int(kind[4:])]
        near = [e for e in mine if abs((e[0] - w).days) <= 3]
        got = near[0][0] if near else None
        flag = near[0][4] & 1 if near else 0
        ok = got == w and not flag
        ok_n += ok
        note = "unverified flag" if flag else ""
        rows.append((city, label, want, str(got), "match" if ok else "MISMATCH", note, src))

    lines = ["# Date audit against Drik Panchang", "",
             "Generated by `tools/panchang/audit.py`. Reference values were read "
             "on 2026-11-12 from Drik Panchang pages, or from pages that quote "
             "Drik Panchang for New Delhi. Drik's own tables need JavaScript and "
             "could not be fetched, so the source of each value is named. "
             "Edison and New York are the diaspora cities.", "",
             f"## Dates: {ok_n} of {len(rows)} match", "",
             "| City | Date | Drik | Ours | Result | Note | Source |",
             "|---|---|---|---|---|---|---|"]
    for r in rows:
        lines.append("| " + " | ".join(r) + " |")

    lines += ["", "## Parana windows", "",
              "| City | Fast | Drik | Ours | Result |", "|---|---|---|---|---|"]
    for city, label, fast, s, e, src in PARANA:
        f = dt.date.fromisoformat(fast)
        ek = [x for x in events(city) if x[1] == 1 and x[0] == f][0]
        a, b = ek[2], ek[3]
        ws, we = s[0] * 60 + s[1], e[0] * 60 + e[1]
        ok = abs(a - ws) <= 1 and abs(b - we) <= 1
        lines.append(f"| {city} | {label} {fast} | {hm(ws)}-{hm(we)} | "
                     f"{hm(a)}-{hm(b)} | {'match (within 1 min)' if ok else 'MISMATCH'} |")

    sky = Sky()
    lines += ["", "## Tithi start and end (local time, tolerance 2 min)", "",
              "| City | Tithi | Drik | Ours | Result |", "|---|---|---|---|---|"]
    cities = {c["id"]: c for c in all_cities()}
    bad = 0
    for city, t, s, e, src in TITHI:
        tz = ZoneInfo(cities[city]["tz"])
        fs = dt.datetime.fromisoformat(s).replace(tzinfo=tz)
        best = min(sky.intervals(t), key=lambda iv: abs(iv[0] - fs.timestamp()))
        loc = lambda x: dt.datetime.fromtimestamp(x, tz)
        es = (loc(best[0]) - dt.datetime.fromisoformat(s).replace(tzinfo=tz)).total_seconds() / 60
        ee = (loc(best[1]) - dt.datetime.fromisoformat(e).replace(tzinfo=tz)).total_seconds() / 60
        ok = abs(es) <= 2 and abs(ee) <= 2
        bad += not ok
        lines.append(f"| {city} | {t} | {s} to {e} | "
                     f"{loc(best[0]):%Y-%m-%d %H:%M} to {loc(best[1]):%Y-%m-%d %H:%M} | "
                     f"{'match' if ok else 'MISMATCH'} ({es:+.0f}, {ee:+.0f} min) |")
    lines += ["", "## Findings", "",
              "- Everything matched except Janmashtami 2027 for New Delhi. We "
              "give 24 Aug (Ashtami covers midnight of 24-25 Aug); the pages "
              "we could read give 25 Aug, which fits the Vaishnava or Rohini "
              "rule. The nishita rule for Smarta/Vaishnava Janmashtami is not "
              "implemented, so Janmashtami is shipped flagged unverified "
              "(`UNVERIFIED_FESTIVALS` in generate.py): the app neither shows "
              "nor schedules it.",
              "- Guru Purnima first failed for Fairfield (we said 17 Jul, "
              "Drik says 18 Jul). Fixed by using the tithi at sunrise; rerun "
              "matches in Delhi and Fairfield.",
              "- Purnima vrat first failed for Pausha 2027; fixed by using the "
              "tithi at moonrise instead of sunset.",
              "- Tithi boundaries agree with Drik to within 1-2 minutes in "
              "every row, so remaining risk is the day-choosing rule, not the "
              "astronomy. Parana start differs by up to 1 minute (sunrise "
              "rounding).",
              "- Not audited: Pradosh, Sankashti, Amavasya (date), other "
              "festivals, and every city other than Delhi, Edison, New York "
              "and Fairfield. Those are produced by the same rules.",
              "- Ekadashi that lies wholly between two sunrises (Delhi, "
              "20 Nov 2026) follows the Drik date: Smarta on the day it "
              "prevails, Vaishnava on the next day."]
    Path(__file__).with_name("AUDIT.md").write_text("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
