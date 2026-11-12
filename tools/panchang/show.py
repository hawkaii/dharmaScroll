#!/usr/bin/env python3
"""Print a city's generated events as readable lines (used for the audit).

    python tools/panchang/show.py new-delhi-in [type ...]
"""
import datetime as dt
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "assets" / "panchang"
NAMES = {1: "Ekadashi (Smarta)", 2: "Ekadashi (Vaishnava)", 3: "Purnima",
         4: "Amavasya", 5: "Pradosh", 6: "Sankashti", 7: "Festival"}


def hm(m):
    return f"{m // 60:02d}:{m % 60:02d}"


def main(city, types):
    data = json.loads((ROOT / f"{city}.json").read_text())
    fest = json.loads((ROOT / "festivals.json").read_text())
    start = dt.date.fromisoformat(data["start"])
    for d, t, a, b, f in data["ev"]:
        if types and t not in types:
            continue
        day = start + dt.timedelta(days=d)
        extra = ""
        if t in (1, 2):
            extra = f" parana {day + dt.timedelta(days=f >> 1)} {hm(a)}-{hm(b)}"
        elif t == 6:
            extra = f" moonrise {hm(a)}"
        elif t == 7:
            extra = f" {fest[str(a)]}"
        print(f"{day} {day:%a} {NAMES[t]}{extra}{' UNVERIFIED' if f & 1 else ''}")


if __name__ == "__main__":
    main(sys.argv[1], {int(x) for x in sys.argv[2:]})
