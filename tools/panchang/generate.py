#!/usr/bin/env python3
"""Precompute Hindu calendar dates for every bundled city.

Skyfield (MIT) + JPL DE421 (US government data). Output: one small JSON per
city plus cities.json in assets/panchang/. Run:

    pip install skyfield==1.55 numpy
    python tools/panchang/generate.py            # all cities
    python tools/panchang/generate.py new-delhi-in edison-us   # a few

Everything here is the single definition of the rules; the app only reads.

File format (version 1), one object per city:
  start   "2026-11-01"  day 0
  n       number of days
  sr0,ss0 sunrise / sunset of day 0, minutes after local midnight
  sun     string with one char per later day for sunrise, then one char per
          later day for sunset: chr(0x50 + delta) where delta is today minus
          yesterday in whole minutes (closed loop, so rounding never drifts)
  ev      list of [day, type, a, b, flag]
          type 1 Ekadashi Smarta, 2 Ekadashi Vaishnava: a,b = parana start/end
                (minutes on the parana day, day+pd), see pd in flag
          type 3 Purnima, 4 Amavasya, 5 Pradosh, 6 Sankashti (a = moonrise min)
          type 7 festival (a = festival id from FESTIVALS)
          flag  bit0 = unverified, bits1.. = parana day offset (Ekadashi)
"""
from __future__ import annotations

import bisect
import datetime as dt
import json
import math
import sys
from pathlib import Path
from zoneinfo import ZoneInfo

import numpy as np
from skyfield import almanac
from skyfield.api import Loader, wgs84

from cities import all_cities

START = dt.date(2026, 11, 1)
END = dt.date(2028, 12, 31)
N = (END - START).days + 1
PAD = 3  # extra days either side so "next sunrise" always exists

OUT = Path(__file__).resolve().parents[2] / "assets" / "panchang"
CACHE = Path(__file__).resolve().parent / ".cache"

# Festival ids are stable; the app maps id -> display name.
# (id, name, amanta month 0=Chaitra..11=Phalguna, tithi 1..30, kala)
FESTIVALS = [
    (1, "Vasant Panchami", 10, 5, "purvahna"),
    (2, "Maha Shivaratri", 10, 29, "nishita"),
    (3, "Holika Dahan", 11, 15, "pradosh"),
    (4, "Ugadi and Gudi Padwa", 0, 1, "sunrise"),
    (5, "Ram Navami", 0, 9, "madhyahna"),
    (6, "Hanuman Jayanti", 0, 15, "sunrise"),
    (7, "Akshaya Tritiya", 1, 3, "purvahna"),
    (8, "Rath Yatra", 3, 2, "sunrise"),
    (9, "Guru Purnima", 3, 15, "sunrise"),
    (10, "Raksha Bandhan", 4, 15, "aparahna"),
    (11, "Janmashtami", 4, 23, "nishita"),
    (12, "Ganesh Chaturthi", 5, 4, "madhyahna"),
    (13, "Radha Ashtami", 5, 8, "madhyahna"),
    (14, "Anant Chaturdashi", 5, 14, "sunrise"),
    (15, "Navratri begins", 6, 1, "sunrise"),
    (16, "Durga Ashtami", 6, 8, "sunrise"),
    (17, "Maha Navami", 6, 9, "sunrise"),
    (18, "Vijayadashami", 6, 10, "aparahna"),
    (19, "Sharad Purnima", 6, 15, "sunset"),
    (20, "Karva Chauth", 6, 19, "moonrise"),
    (21, "Dhanteras", 6, 28, "pradosh"),
    (22, "Naraka Chaturdashi", 6, 29, "sunrise"),
    (23, "Diwali", 6, 30, "pradosh"),
    (24, "Govardhan Puja", 7, 1, "sunrise"),
    (25, "Bhai Dooj", 7, 2, "aparahna"),
    (26, "Tulsi Vivah", 7, 12, "sunrise"),
    (27, "Dev Deepawali", 7, 15, "pradosh"),
    (28, "Makar Sankranti", None, None, "sankranti"),
    (29, "Gita Jayanti", 8, 11, "ekadashi"),
    (30, "Holi", 11, 15, "pradosh+1"),
]


# Festivals whose date did not match Drik Panchang in tools/panchang/AUDIT.md.
# Shipped flagged unverified; the app neither shows nor schedules them.
UNVERIFIED_FESTIVALS = {11}


def load_sky():
    CACHE.mkdir(exist_ok=True)
    load = Loader(str(CACHE))
    return load.timescale(), load("de421.bsp")


class Sky:
    """Universal (city independent) tables: tithi boundaries, lunations."""

    def __init__(self):
        self.ts, self.eph = load_sky()
        self.earth, self.sun, self.moon = (
            self.eph["earth"], self.eph["sun"], self.eph["moon"])
        t0 = self.ts.utc(2026, 9, 1)
        t1 = self.ts.utc(2029, 2, 1)

        def tithi_idx(t):
            return (almanac.moon_phase(self.eph, t).degrees // 12).astype(int)
        tithi_idx.step_days = 0.5
        t, y = almanac.find_discrete(t0, t1, tithi_idx)
        self.tb_t = [x.timestamp() for x in t.utc_datetime()]
        self.tb_i = [int(v) for v in y]  # 0..29 after the boundary

        def sign(t):
            return (self.sid_lon(t) // 30).astype(int)
        sign.step_days = 1.0
        # new moons and sankrantis
        self.nm = [self.tb_t[k] for k, i in enumerate(self.tb_i) if i == 0]
        ts_ = [self.ts.from_datetime(
            dt.datetime.fromtimestamp(s, dt.timezone.utc)) for s in self.nm]
        self.nm_sign = [int(self.sid_lon(x) // 30) for x in ts_]
        sk_t, sk_y = almanac.find_discrete(t0, t1, sign)
        self.sankranti = [(x.timestamp(), int(v))
                          for x, v in zip(sk_t.utc_datetime(), sk_y)]
        # lunations: name 0=Chaitra.., adhika flag
        self.lun = []
        for i in range(len(self.nm) - 1):
            s0, s1 = self.nm_sign[i], self.nm_sign[i + 1]
            self.lun.append(((s0 + 1) % 12, s0 == s1))

    def sid_lon(self, t):
        lon = self.earth.at(t).observe(self.sun).apparent() \
            .ecliptic_latlon(epoch="date")[1].degrees
        years = (t.tt - 2451545.0) / 365.25
        return (lon - (23.85306 + 0.013969 * years)) % 360

    def tithi_at(self, s: float) -> int:
        k = bisect.bisect_right(self.tb_t, s) - 1
        return self.tb_i[k] + 1

    def month_at(self, s: float):
        k = bisect.bisect_right(self.nm, s) - 1
        return self.lun[k] if 0 <= k < len(self.lun) else (-1, True)

    def intervals(self, tithi: int):
        """(start, end) epoch seconds of every instance of a tithi."""
        out = []
        for k in range(len(self.tb_t) - 1):
            if self.tb_i[k] == tithi - 1:
                out.append((self.tb_t[k], self.tb_t[k + 1]))
        return out


class City:
    def __init__(self, sky: Sky, c: dict):
        self.sky, self.c = sky, c
        self.tz = ZoneInfo(c["tz"])
        self.topos = wgs84.latlon(c["lat"], c["lon"])
        self.sr, self.ss = self._sun_times()

    # ---- day helpers; day index d in [-PAD, N+PAD)
    def date(self, d: int) -> dt.date:
        return START + dt.timedelta(days=d)

    def local_day(self, s: float) -> int:
        return (dt.datetime.fromtimestamp(s, self.tz).date() - START).days

    def minute(self, s: float) -> int:
        x = dt.datetime.fromtimestamp(s, self.tz)
        return x.hour * 60 + x.minute + (1 if x.second >= 30 else 0)

    def _sun_times(self):
        lo = self.date(-PAD - 1)
        hi = self.date(N + PAD + 1)
        ts = self.sky.ts
        t0 = ts.from_datetime(dt.datetime(lo.year, lo.month, lo.day,
                                          tzinfo=dt.timezone.utc))
        t1 = ts.from_datetime(dt.datetime(hi.year, hi.month, hi.day,
                                          tzinfo=dt.timezone.utc))
        t, y = almanac.find_discrete(
            t0, t1, almanac.sunrise_sunset(self.sky.eph, self.topos))
        sr, ss = {}, {}
        for x, v in zip(t.utc_datetime(), y):
            s = x.timestamp()
            (sr if v == 1 else ss)[self.local_day(s)] = s
        for d in range(-PAD, N + PAD):
            if d not in sr or d not in ss:
                raise RuntimeError(f"{self.c['id']}: no sunrise/sunset on {d}")
        return sr, ss

    def moonrise(self, d: int):
        """Moonrise (epoch s) on local day d, or None. 10-minute scan."""
        a = dt.datetime.combine(self.date(d), dt.time(), self.tz)
        base = a.timestamp()
        secs = base + np.arange(0, 26 * 3600, 600)
        ts = self.sky.ts
        times = ts.utc(1970, 1, 1, 0, 0, secs)
        alt = (self.sky.earth + self.topos).at(times).observe(self.sky.moon) \
            .apparent().altaz()[0].degrees
        h = -0.5667 - 0.2725 * 0.9507  # refraction + upper limb
        for k in range(len(alt) - 1):
            if alt[k] < h <= alt[k + 1]:
                s = secs[k] + 600 * (h - alt[k]) / (alt[k + 1] - alt[k])
                if self.local_day(s) == d:
                    return float(s)
        return None

    # ---- kala instants
    def kala(self, name: str, d: int):
        sr, ss = self.sr[d], self.ss[d]
        D = ss - sr
        return {
            "sunrise": sr,
            "purvahna": sr + 0.2 * D,
            "madhyahna": sr + 0.5 * D,
            "aparahna": sr + 0.6 * D,
            "sunset": ss,
            "pradosh": ss + 72 * 60,
            "nishita": ss + (self.sr[d + 1] - ss) / 2,
        }[name] if name != "moonrise" else self.moonrise(d)

    def pick(self, iv, kala: str):
        """Day on which tithi interval iv covers the kala instant.
        Returns (day, ok); ok False means a fallback day was used."""
        s, e = iv
        d0 = self.local_day(s) - 1
        for d in range(d0, d0 + 4):
            if d < -PAD or d >= N + PAD:
                continue
            k = self.kala(kala, d)
            if k is not None and s <= k < e:
                return d, True
        # kshaya at the kala: use the day holding the middle of the tithi
        return self.local_day((s + e) / 2), False


# --------------------------------------------------------------------- rules
def in_range(d):
    return 0 <= d < N


def ekadashi(city: City):
    """Smarta and Vaishnava Ekadashi with parana. Rules (see AUDIT.md):
    Smarta: day whose sunrise has Ekadashi (first of two). If Dvadashi would
      end before the next sunrise (no parana inside Dvadashi), the day before.
    Vaishnava: second day when two; if Dashami touches arunodaya (96 min
      before sunrise) the next day; else the sunrise day.
    """
    sky = city.sky
    out = []
    for tithi in (11, 26):
        for s, e in sky.intervals(tithi):
            if city.local_day(e) < 0 or city.local_day(s) > N - 1:
                continue
            days = [d for d in range(city.local_day(s) - 1, city.local_day(e) + 2)
                    if -PAD <= d < N + PAD and s <= city.sr[d] < e]
            kshaya = not days
            k = bisect.bisect_right(sky.tb_t, e) - 1
            dv_e = sky.tb_t[k + 1]  # end of the Dvadashi that follows
            if kshaya:  # wholly between two sunrises: Smarta takes the day it
                # prevails, Vaishnava the next (Dvadashi at sunrise)
                d1 = city.local_day(e) + (0 if city.sr[city.local_day(e)] > e else 1)
                smarta, vaish = d1 - 1, d1
            else:
                d = days[0]
                smarta = d
                if dv_e < city.sr[d + 1] and city.ss[d - 1] > s:
                    smarta = d - 1  # no parana possible inside Dvadashi
                if len(days) == 2:
                    vaish = days[1]
                elif sky.tithi_at(city.sr[d] - 96 * 60) == tithi - 1:
                    vaish = d + 1  # Dashami touches arunodaya
                else:
                    vaish = d
            for typ, fd in ((1, smarta), (2, vaish)):
                if not (in_range(fd) or in_range(fd + 1)):
                    continue
                a, b, pd = parana(city, fd, e, dv_e)
                out.append((fd, typ, a, b, pd << 1, s, tithi))
    return out


def parana(city: City, fd: int, ek_end: float, dv_end: float):
    """Parana window (minutes, parana-day offset) after a fast on day fd."""
    sky = city.sky
    k = bisect.bisect_right(sky.tb_t, ek_end) - 1
    dv_start, dv_stop = sky.tb_t[k], sky.tb_t[k + 1]
    hari_vasara_end = dv_start + (dv_stop - dv_start) / 4
    for pd in (1, 2, 3):
        p = fd + pd
        sr = city.sr[p]
        if sr < ek_end:  # Ekadashi still running at sunrise: not a parana day
            continue
        D = city.ss[p] - sr
        start = max(sr, hari_vasara_end)
        end = sr + D / 5  # end of pratahkal
        if start >= end:  # Hari Vasara runs past pratahkal: until madhyahna
            end = sr + 3 * D / 5
        if dv_stop > start:
            end = min(end, dv_stop)
        if end > start:
            return city.minute(start), city.minute(end), pd
    return city.minute(city.sr[fd + 1]), city.minute(city.sr[fd + 1] + 7200), 1


def build(sky: Sky, c: dict):
    city = City(sky, c)
    ev = []  # [day, type, a, b, flag]
    eks = ekadashi(city)
    for fd, typ, a, b, flag, _s, _t in eks:
        if in_range(fd):
            ev.append([fd, typ, a, b, flag])

    # Purnima (moonrise), Amavasya (aparahna), Pradosh (mid-pradosh), Sankashti
    for tithi, typ, kala in ((15, 3, "moonrise"), (30, 4, "aparahna"),
                             (13, 5, "pradosh"), (28, 5, "pradosh"),
                             (19, 6, "moonrise")):
        for iv in sky.intervals(tithi):
            d, ok = city.pick(iv, kala)
            if not in_range(d):
                continue
            a = 0
            if typ == 6:
                mr = city.moonrise(d)
                a = city.minute(mr) if mr else 0
            ev.append([d, typ, a, 0, 0 if ok else 1])

    # Festivals by lunar month and tithi
    for fid, _name, month, tithi, kala in FESTIVALS:
        if kala == "sankranti":
            for s, sign in sky.sankranti:
                if sign == 9:  # sidereal Makara
                    d = city.local_day(s)
                    if not -PAD <= d < N + PAD:
                        continue
                    if s >= city.ss[d]:
                        d += 1
                    if in_range(d):
                        ev.append([d, 7, fid, 0, 0])
            continue
        if kala == "ekadashi":
            for fd, typ, _a, _b, flag, s, t in eks:
                m, adhika = sky.month_at(s)
                if t == 11 and m == month and not adhika and in_range(fd):
                    ev.append([fd, 7, fid, typ, flag])
            continue
        shift = 0
        if kala.endswith("+1"):
            kala, shift = kala[:-2], 1
        for iv in sky.intervals(tithi):
            m, adhika = sky.month_at(iv[0] + 1)
            if m != month or adhika:
                continue
            d, ok = city.pick(iv, kala)
            d += shift
            if in_range(d):
                ev.append([d, 7, fid, 0, 0 if ok and fid not in UNVERIFIED_FESTIVALS else 1])

    ev.sort()
    sr = [city.minute(city.sr[d]) for d in range(N)]
    ss = [city.minute(city.ss[d]) for d in range(N)]

    def deltas(v):
        out = []
        for a, b in zip(v, v[1:]):
            dlt = b - a
            # A DST change moves the clock by 30-60 min in one day: escape it.
            out.append(chr(0x50 + dlt) if abs(dlt) <= 10 else f"{{{dlt};")
        return "".join(out)

    return {
        "v": 1, "start": START.isoformat(), "n": N,
        "sr0": sr[0], "ss0": ss[0], "sun": deltas(sr) + deltas(ss),
        "ev": ev,
    }


def main(argv):
    cities = all_cities()
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "festivals.json").write_text(json.dumps(
        {str(f[0]): f[1] for f in FESTIVALS}, separators=(",", ":")))
    (OUT / "cities.json").write_text(json.dumps(
        cities, ensure_ascii=False, separators=(",", ":")))
    want = set(argv)
    sky = Sky()
    for i, c in enumerate(cities):
        if want and c["id"] not in want:
            continue
        data = build(sky, c)
        (OUT / f"{c['id']}.json").write_text(
            json.dumps(data, separators=(",", ":")))
        print(f"{i + 1}/{len(cities)} {c['id']} {len(data['ev'])} events",
              flush=True)


if __name__ == "__main__":
    main(sys.argv[1:])
