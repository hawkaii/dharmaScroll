#!/usr/bin/env python3
"""Writes the small explainer Lotties in assets/lottie/.

Run from the repo root:  python3 tools/lottie_gen/gen.py

Rules (Flutter's `lottie` package renders these faithfully):
- shape layers only: paths, ellipses, rects, strokes, fills, trim paths, dashes
- no effects, masks, mattes, expressions, text layers or images
- colours are the board v3 tokens (lib/design/tokens.dart), baked in
- line icons follow the board: round caps and joins, a soft wide stroke as glow
- symbols only: no figures and no faces

Each file is either played once and held, or played once and then loops a
settled segment. `LOOP_FROM` below lists that segment start per file; the
Flutter widget (`DLottie`) reads the same numbers.
"""

import json
import math
import os

FR = 60
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "lottie")

# Board v3 tokens (dark, "Temple Night").
HEX = {
    "marigold": "FFC247",
    "saffron": "F28C28",
    "gold": "F7D58B",
    "rose": "E58BA3",
    "peacock": "4FB3AB",
    "ink": "FBEFD9",
    "mute": "C9B2B8",
    "faint": "8F7A8C",
    "flame": "FFB03B",
    "core": "FFF3CF",
}


def col(name):
    h = HEX[name]
    return [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)] + [1]


# ----------------------------------------------------------------- easing
EASE = {
    # motion-taste anchors (x1, y1, x2, y2)
    "settle": (0.0, 0.65, 0.51, 0.99),
    "enter": (0.20, 0.75, 0.34, 0.94),
    "travel": (0.65, 0.0, 0.35, 1.0),
    "sine": (0.42, 0.0, 0.58, 1.0),
    "exit": (1.0, 0.02, 0.54, 0.42),
    "lin": (0.0, 0.0, 1.0, 1.0),
    "pop": (0.22, 1.2, 0.36, 1.0),  # Motion.spring in tokens.dart
}


def st(v):
    return {"a": 0, "k": v}


def _wrap(v):
    return v if isinstance(v, list) else [v]


def anim(*frames):
    """frames: (t, value) or (t, value, ease). Ease applies to the segment
    leaving that keyframe (Lottie stores both handles on the start key)."""
    ks = []
    for n, f in enumerate(frames):
        t, v = f[0], f[1]
        e = f[2] if len(f) > 2 else "sine"
        k = {"t": t, "s": _wrap(v)}
        if n < len(frames) - 1:
            if e == "hold":
                k["h"] = 1
            else:
                x1, y1, x2, y2 = EASE[e]
                k["o"] = {"x": [x1], "y": [y1]}
                k["i"] = {"x": [x2], "y": [y2]}
        ks.append(k)
    return {"a": 1, "k": ks}


def anim_shape(*frames):
    ks = []
    for n, f in enumerate(frames):
        t, v = f[0], f[1]
        e = f[2] if len(f) > 2 else "sine"
        k = {"t": t, "s": [v]}
        if n < len(frames) - 1:
            if e == "hold":
                k["h"] = 1
            else:
                x1, y1, x2, y2 = EASE[e]
                k["o"] = {"x": [x1], "y": [y1]}
                k["i"] = {"x": [x2], "y": [y2]}
        ks.append(k)
    return {"a": 1, "k": ks}


# ----------------------------------------------------------------- shapes
def tr(p=(0, 0), a=(0, 0), s=None, r=None, o=None):
    return {
        "ty": "tr",
        "p": p if isinstance(p, dict) else st(list(p)),
        "a": st(list(a)),
        "s": s if isinstance(s, dict) else st([100, 100]),
        "r": r if isinstance(r, dict) else st(0),
        "o": o if isinstance(o, dict) else st(100),
        "sk": st(0),
        "sa": st(0),
    }


def group(items, **t):
    return {"ty": "gr", "it": items + [tr(**t)]}


def stroke(c="marigold", w=4.0, o=100, dash=None):
    s = {"ty": "st", "c": st(col(c)), "o": o if isinstance(o, dict) else st(o),
         "w": st(w), "lc": 2, "lj": 2, "ml": 4}
    if dash:
        s["d"] = [{"n": "d", "nm": "dash", "v": st(dash[0])},
                  {"n": "g", "nm": "gap", "v": st(dash[1])},
                  {"n": "o", "nm": "offset", "v": st(0)}]
    return s


def fill(c="marigold", o=100):
    return {"ty": "fl", "c": st(col(c)), "o": o if isinstance(o, dict) else st(o), "r": 1}


def trim(e, s=None):
    return {"ty": "tm", "s": s if isinstance(s, dict) else st(0),
            "e": e if isinstance(e, dict) else st(e), "o": st(0), "m": 1}


def ellipse(cx, cy, w, h=None):
    return {"ty": "el", "p": st([cx, cy]), "s": st([w, w if h is None else h]), "d": 1}


def rect(cx, cy, w, h, r=0):
    return {"ty": "rc", "p": st([cx, cy]), "s": st([w, h]), "r": st(r), "d": 1}


def shape_data(v, i=None, o=None, closed=False):
    z = [[0, 0]] * len(v)
    return {"v": v, "i": i or z, "o": o or z, "c": closed}


def path(v, i=None, o=None, closed=False):
    return {"ty": "sh", "ks": st(shape_data(v, i, o, closed)), "d": 1}


def bez(start, *segs, closed=False):
    """SVG-like cubic path: bez((x,y), (c1, c2, end), ...). Absolute points."""
    v, ins, outs = [list(start)], [[0, 0]], [[0, 0]]
    for c1, c2, end in segs:
        outs[-1] = [c1[0] - v[-1][0], c1[1] - v[-1][1]]
        v.append(list(end))
        ins.append([c2[0] - end[0], c2[1] - end[1]])
        outs.append([0, 0])
    if closed and v[-1] == v[0] and len(v) > 1:
        ins[0] = ins[-1]
        v.pop(), ins.pop(), outs.pop()
    return {"ty": "sh", "ks": st({"v": v, "i": ins, "o": outs, "c": closed}), "d": 1}


def line(*pts):
    return path([list(p) for p in pts])


def layer(name, shapes, ip=0, op=None, o=None, p=None, a=(0, 0), s=None, r=None, ind=1):
    return {
        "ty": 4, "nm": name, "ind": ind, "ip": ip, "op": op, "st": 0, "sr": 1,
        "ks": {
            "o": o if isinstance(o, dict) else st(100),
            "r": r if isinstance(r, dict) else st(0),
            "p": p if isinstance(p, dict) else st([0, 0, 0] if p is None else list(p) + [0]),
            "a": st(list(a) + [0]),
            "s": s if isinstance(s, dict) else st([100, 100, 100]),
        },
        "shapes": shapes, "ao": 0, "bm": 0,
    }


def doc(name, w, h, op, layers):
    for n, l in enumerate(layers):
        l["ind"] = n + 1
        if l["op"] is None:
            l["op"] = op
    return {"v": "5.7.0", "fr": FR, "ip": 0, "op": op, "w": w, "h": h,
            "nm": name, "ddd": 0, "assets": [], "layers": layers}


def draw_on(t0, t1, ease="settle"):
    return anim((t0, 0, ease), (t1, 100))


def lined(shapes, c="marigold", w=4.0, glow=True, on=None):
    """A line drawing with an optional soft glow stroke and a draw-on."""
    items = list(shapes)
    if on:
        items.append(trim(draw_on(*on)))
    items.append(stroke(c, w))
    out = [group(items)]
    if glow:
        g = list(shapes)
        if on:
            g.append(trim(draw_on(*on)))
        g.append(stroke(c, w * 2.6, o=16))
        out.append(group(g))
    return out


# ----------------------------------------------------------------- the diya
def flame_shapes(cx, base, h):
    """Teardrop flame, base centred at (cx, base), height h."""
    w = h * 0.36
    top = base - h

    def drop(scale, c):
        hh, ww = h * scale, w * scale
        tp = base - hh
        return group([
            bez((cx, tp),
                ((cx + ww * 0.45, tp + hh * 0.32), (cx + ww, tp + hh * 0.52), (cx + ww, tp + hh * 0.70)),
                ((cx + ww, tp + hh * 0.88), (cx + ww * 0.55, base), (cx, base)),
                ((cx - ww * 0.55, base), (cx - ww, tp + hh * 0.88), (cx - ww, tp + hh * 0.70)),
                ((cx - ww, tp + hh * 0.52), (cx - ww * 0.45, tp + hh * 0.32), (cx, tp)),
                closed=True),
            fill(c),
        ])

    glow = group([ellipse(cx, top + h * 0.62, h * 1.25, h * 1.35), fill("marigold", 14)])
    return [drop(0.5, "core"), drop(1, "flame"), glow]


def diya_bowl(cx, cy, w, sw, c="marigold", on=None):
    """Bowl: a lip ellipse and a curved belly, as lines."""
    hw = w / 2
    belly = bez((cx - hw, cy),
                ((cx - hw * 0.86, cy + w * 0.30), (cx - hw * 0.45, cy + w * 0.36), (cx, cy + w * 0.36)),
                ((cx + hw * 0.45, cy + w * 0.36), (cx + hw * 0.86, cy + w * 0.30), (cx + hw, cy)))
    lip = ellipse(cx, cy, w, w * 0.14)
    return lined([belly, lip], c=c, w=sw, on=on)


def small_diya(cx, cy, c, lit_at, op, w=22):
    """A tiny lamp for timelines: filled bowl + flame that lights at lit_at."""
    bowl = group([
        bez((cx - w / 2, cy),
            ((cx - w * 0.43, cy + w * 0.3), (cx - w * 0.2, cy + w * 0.36), (cx, cy + w * 0.36)),
            ((cx + w * 0.2, cy + w * 0.36), (cx + w * 0.43, cy + w * 0.3), (cx + w / 2, cy)),
            closed=True),
        fill(c),
    ])
    fl = group(flame_shapes(cx, cy - 1, w * 0.62),
               p=(cx, cy - 1), a=(cx, cy - 1),
               s=anim((lit_at, [0, 0], "pop"), (lit_at + 24, [100, 100])))
    return [fl, bowl]


def flicker(t0, t1, period=60):
    """Rotation and scale keyframes for a calm flame, seamless over [t0, t1]."""
    rot, sc = [], []
    t, n = t0, 0
    while t < t1:
        rot.append((t, [-1.6 if n % 2 else 1.6], "sine"))
        sc.append((t, [100, 100, 100] if n % 2 else [97, 104, 100], "sine"))
        t += period // 2
        n += 1
    rot.append((t1, rot[0][1]))
    sc.append((t1, sc[0][1]))
    return rot, sc


# ----------------------------------------------------------------- scenes
LOOP_FROM = {}


def hour_diya():
    op = 240
    cx, lip = 64, 82
    rot, sc = flicker(80, op)
    flame = group(
        [group(flame_shapes(cx, lip - 4, 40))],
        p=(cx, lip - 4), a=(cx, lip - 4),
        s=anim((36, [0, 0], "pop"), (70, [100, 100])),
    )
    flame_layer = layer("flame", [flame], p=(cx, lip - 4), a=(cx, lip - 4),
                        r=anim(*rot), s=anim(*sc))
    wick = group([line((cx, lip - 1), (cx, lip - 6)), stroke("marigold", 3)])
    bowl = layer("bowl", diya_bowl(cx, lip, 72, 4, on=(0, 42)) + [wick])
    LOOP_FROM["hour_diya"] = 80
    return doc("Hour diya", 128, 128, op, [flame_layer, bowl])


def two_paths():
    op = 240
    stem = lined([line((80, 124), (80, 90))], on=(0, 26))
    left = lined([bez((80, 90), ((80, 70), (44, 70), (40, 46)))], on=(22, 62))
    right = lined([bez((80, 90), ((80, 70), (116, 70), (120, 46)))], c="rose", on=(30, 70))
    lamps = small_diya(40, 36, "marigold", 62, op, w=26) + small_diya(120, 36, "rose", 74, op, w=26)
    LOOP_FROM["two_paths"] = 100
    lamp_layer = layer("lamps", lamps,
                       o=anim((56, 0, "settle"), (66, 100)))
    breathe = layer("breathe", [group([ellipse(40, 26, 34), fill("marigold", 10)]),
                                group([ellipse(120, 26, 34), fill("rose", 10)])],
                    o=anim((100, 100), (170, 40), (240, 100)))
    return doc("Two paths", 160, 128, op, [breathe, lamp_layer, layer("lines", stem + left + right)])


def city_sun():
    op = 240
    hz = 112
    horizon = lined([line((14, hz), (186, hz))], c="faint", w=2.5, glow=False, on=(0, 30))
    # A temple shikhara with a flag, two small domes, a few blocks.
    temple = bez((30, hz),
                 ((30, 96), (34, 90), (38, 86)),
                 ((42, 76), (46, 66), (50, 58)),
                 ((54, 66), (58, 76), (62, 86)),
                 ((66, 90), (70, 96), (70, hz)))
    flag = line((50, 58), (50, 46), (58, 50), (50, 52))
    dome = bez((74, hz), ((74, 98), (88, 98), (88, hz)))
    blocks = path([[128, hz], [128, 88], [146, 88], [146, hz]])
    tower = path([[150, hz], [150, 76], [164, 76], [164, hz]])
    low = path([[168, hz], [168, 96], [182, 96], [182, hz]])
    city = lined([temple, flag, dome, blocks, tower, low], c="mute", w=3, glow=False, on=(10, 60))
    sun_body = [group([ellipse(102, 0, 34), fill("marigold")]),
                group([ellipse(102, 0, 58), fill("marigold", 16)])]
    sun = layer("sun", sun_body,
                p=anim((30, [0, 112, 0], "settle"), (110, [0, 76, 0])),
                o=anim((30, 0, "settle"), (60, 100)))
    rays = []
    for k in range(8):
        ang = math.radians(-90 + k * 45)
        r0, r1 = 26, 34
        rays.append(line((102 + r0 * math.cos(ang), r0 * math.sin(ang)),
                         (102 + r1 * math.cos(ang), r1 * math.sin(ang))))
    ray_layer = layer("rays", [group(rays + [trim(draw_on(96, 130)), stroke("marigold", 3)])],
                      p=st([102, 76, 0]), a=(102, 0),
                      s=anim((130, [100, 100, 100]), (185, [108, 108, 100]), (240, [100, 100, 100])),
                      o=anim((96, 0, "settle"), (110, 100)))
    LOOP_FROM["city_sun"] = 130
    return doc("City sunrise", 200, 140, op, [layer("city", city + horizon), ray_layer, sun])


def lotus_safe():
    op = 240
    cx, by = 64, 92
    mid = bez((cx, by), ((cx - 16, by - 22), (cx - 10, by - 48), (cx, by - 62)),
              ((cx + 10, by - 48), (cx + 16, by - 22), (cx, by)))
    left = bez((cx - 4, by), ((cx - 34, by - 6), (cx - 44, by - 26), (cx - 42, by - 44)),
               ((cx - 26, by - 40), (cx - 12, by - 24), (cx - 4, by)))
    right = bez((cx + 4, by), ((cx + 34, by - 6), (cx + 44, by - 26), (cx + 42, by - 44)),
                ((cx + 26, by - 40), (cx + 12, by - 24), (cx + 4, by)))
    water = line((cx - 40, by + 10), (cx + 40, by + 10))
    petals = lined([mid], c="rose", on=(0, 50)) + lined([left, right], c="rose", on=(14, 64))
    base = lined([water], c="faint", w=2.5, glow=False, on=(40, 80))
    light = layer("light", [group([ellipse(cx, by - 20, 12), fill("marigold")]),
                            group([ellipse(cx, by - 20, 30), fill("marigold", 18)])],
                  p=st([cx, by - 20, 0]), a=(cx, by - 20),
                  s=anim((60, [0, 0, 100], "pop"), (90, [100, 100, 100]), (165, [116, 116, 100]),
                         (240, [100, 100, 100])))
    LOOP_FROM["lotus_safe"] = 90
    return doc("Lotus light", 128, 128, op, [light, layer("lotus", petals + base)])


def trishul():
    op = 240
    cx = 64
    shaft = line((cx, 46), (cx, 116))
    spear = path([[cx, 12], [cx + 6, 30], [cx, 42], [cx - 6, 30]], closed=True)
    left = bez((cx - 3, 54), ((cx - 22, 54), (cx - 28, 44), (cx - 26, 24)))
    right = bez((cx + 3, 54), ((cx + 22, 54), (cx + 28, 44), (cx + 26, 24)))
    tipl = path([[cx - 30, 30], [cx - 26, 20], [cx - 21, 29]])
    tipr = path([[cx + 30, 30], [cx + 26, 20], [cx + 21, 29]])
    bar = line((cx - 10, 62), (cx + 10, 62))
    # Three bilva leaves at the base, as a small offering.
    leaves = []
    for dx, rot in ((-12, -40), (0, 0), (12, 40)):
        a = math.radians(rot)

        def P(x, y):
            return (cx + dx + x * math.cos(a) - y * math.sin(a), 116 + x * math.sin(a) + y * math.cos(a))
        leaves.append(bez(P(0, 0), (P(-6, -4), P(-5, -12), P(0, -16)), (P(5, -12), P(6, -4), P(0, 0)),
                          closed=True))
    lines = (lined([shaft, bar], on=(0, 40)) + lined([spear], on=(20, 60))
             + lined([left, right, tipl, tipr], on=(30, 76)))
    leaf = layer("bilva", [group(leaves + [fill("peacock", 70)])],
                 o=anim((70, 0, "settle"), (96, 100)))
    glow = layer("aura", [group([ellipse(cx, 44, 70), fill("marigold", 9)])],
                 o=anim((80, 0, "settle"), (110, 100), (175, 45), (240, 100)))
    LOOP_FROM["trishul"] = 110
    return doc("Trishul", 128, 128, op, [layer("trishul", lines), leaf, glow])


def gada():
    op = 240
    cx = 64
    shaft = line((cx, 62), (cx, 116))
    grip = line((cx - 5, 106), (cx + 5, 106))
    head = ellipse(cx, 42, 40, 42)
    band1 = bez((cx - 19, 36), ((cx - 8, 41), (cx + 8, 41), (cx + 19, 36)))
    band2 = bez((cx - 19, 50), ((cx - 8, 55), (cx + 8, 55), (cx + 19, 50)))
    fin = line((cx, 21), (cx, 13))
    knob = ellipse(cx, 10, 6)
    lines = (lined([shaft, grip], on=(0, 36)) + lined([head], on=(16, 70))
             + lined([band1, band2, fin, knob], on=(50, 96)))
    LOOP_FROM["gada"] = 100
    sway = layer("gada", lines, p=st([cx, 116, 0]), a=(cx, 116),
                 r=anim((0, 0), (100, 0), (170, 3), (240, 0)))
    glow = layer("aura", [group([ellipse(cx, 40, 70), fill("saffron", 10)])],
                 o=anim((80, 0, "settle"), (110, 100), (175, 40), (240, 100)))
    return doc("Gada", 128, 128, op, [sway, glow])


def chakra():
    op = 420
    cx = cy = 64
    ring = ellipse(cx, cy, 80)
    inner = ellipse(cx, cy, 58)
    hub = ellipse(cx, cy, 14)
    spokes = []
    for k in range(8):
        a = math.radians(k * 45)
        spokes.append(line((cx + 8 * math.cos(a), cy + 8 * math.sin(a)),
                           (cx + 28 * math.cos(a), cy + 28 * math.sin(a))))
    teeth = []
    for k in range(16):
        a = math.radians(k * 22.5 + 11.25)
        teeth.append(line((cx + 41 * math.cos(a), cy + 41 * math.sin(a)),
                          (cx + 47 * math.cos(a), cy + 47 * math.sin(a))))
    lines = (lined([ring], on=(0, 44)) + lined([inner, hub], c="gold", w=3, on=(10, 50))
             + lined(spokes, c="gold", w=3, on=(24, 60)) + lined(teeth, on=(36, 60)))
    LOOP_FROM["chakra"] = 60
    spin = layer("chakra", lines, p=st([cx, cy, 0]), a=(cx, cy),
                 r=anim((0, 0, "hold"), (60, 0, "lin"), (op, 360)))
    return doc("Chakra", 128, 128, op, [spin])


def shani_lamp():
    op = 240
    cx, lip = 64, 86
    flame = layer("flame", [group([group(flame_shapes(cx, lip - 4, 34))],
                                  p=(cx, lip - 4), a=(cx, lip - 4),
                                  s=anim((30, [0, 0], "pop"), (60, [100, 100])))],
                  p=(cx, lip - 4), a=(cx, lip - 4),
                  s=anim((60, [100, 100, 100]), (150, [96, 104, 100]), (240, [100, 100, 100])))
    dots = []
    for k in range(7):
        a = math.radians(-90 + (k - 3) * 30)
        x, y = cx + 44 * math.cos(a), lip - 20 + 44 * math.sin(a)
        t = 60 + k * 8
        dots.append(layer(f"dot{k}", [group([ellipse(x, y, 5), fill("gold")])],
                          o=anim((t, 0, "settle"), (t + 16, 100), (150 + k * 4, 45), (240, 100))))
    bowl = layer("bowl", diya_bowl(cx, lip, 64, 4, on=(0, 36)))
    LOOP_FROM["shani_lamp"] = 116
    return doc("Saturday lamp", 128, 128, op, [flame, bowl] + dots)


def moon():
    op = 300
    cx, cy, r = 64, 60, 32
    k = 0.5523

    def lit(t):
        """Lit part of the moon, right side out; terminator x offset t."""
        return shape_data(
            [[cx, cy - r], [cx + r, cy], [cx, cy + r], [cx + t, cy]],
            i=[[t * k, 0], [0, -r * k], [r * k, 0], [0, r * k]],
            o=[[r * k, 0], [0, r * k], [t * k, 0], [0, -r * k]],
            closed=True)

    disc = {"ty": "sh", "ks": anim_shape((0, lit(0.62 * r), "sine"), (120, lit(-r), "hold"),
                                         (160, lit(-r), "sine"), (280, lit(0.62 * r), "hold"),
                                         (op, lit(0.62 * r))), "d": 1}
    moon_l = layer("moon", [group([disc, fill("gold")])],
                   o=anim((0, 0, "settle"), (24, 100)))
    outline = layer("outline", [group([ellipse(cx, cy, 2 * r), stroke("faint", 2, o=60)])])
    stars = []
    for n, (x, y) in enumerate(((18, 24), (108, 18), (112, 100))):
        stars.append(layer(f"star{n}", [group([ellipse(x, y, 4), fill("ink")])],
                           o=anim((n * 40, 20), (n * 40 + 60, 90), (n * 40 + 120, 20), (op, 20))))
    LOOP_FROM["moon"] = 0
    return doc("Moon", 128, 128, op, [moon_l, outline] + stars)


def bell():
    op = 150
    cx = 64
    body = bez((cx - 30, 92),
               ((cx - 22, 84), (cx - 24, 70), (cx - 22, 56)),
               ((cx - 20, 40), (cx - 10, 32), (cx, 32)),
               ((cx + 10, 32), (cx + 20, 40), (cx + 22, 56)),
               ((cx + 24, 70), (cx + 22, 84), (cx + 30, 92)))
    rim = line((cx - 32, 92), (cx + 32, 92))
    loop = ellipse(cx, 26, 10)
    clap = [group([ellipse(cx, 100, 10), fill("marigold")])]
    swing = layer("bell", lined([body, rim, loop]) + clap, p=st([cx, 22, 0]), a=(cx, 22),
                  r=anim((0, 0, "sine"), (14, 12), (32, -9), (50, 5), (68, -2), (86, 0)))
    waves = []
    for side in (-1, 1):
        for n in range(2):
            x0 = cx + side * (42 + n * 10)
            arc = bez((x0, 50), ((x0 + side * 8, 58), (x0 + side * 8, 74), (x0, 82)))
            t = 12 + n * 12
            waves.append(layer(f"wave{side}{n}", [group([arc, stroke("gold", 3)])],
                               o=anim((0, 0, "hold"), (t, 0, "settle"), (t + 10, 90, "exit"),
                                      (t + 50, 0, "hold"), (op, 0))))
    LOOP_FROM["bell"] = 0
    return doc("Bell", 128, 128, op, [swing] + waves)


def ripple():
    op = 120
    cx = cy = 64
    dot = layer("touch", [group([ellipse(cx, cy, 22), fill("marigold")])],
                p=st([cx, cy, 0]), a=(cx, cy),
                s=anim((0, [100, 100, 100], "sine"), (10, [84, 84, 100], "pop"),
                       (30, [100, 100, 100], "hold"), (op, [100, 100, 100])))
    rings = []
    for n in range(3):
        t = 8 + n * 14
        rings.append(layer(f"ring{n}", [group([ellipse(cx, cy, 24), stroke("gold", 1.6)])],
                           p=st([cx, cy, 0]), a=(cx, cy),
                           s=anim((0, [100, 100, 100], "hold"), (t, [100, 100, 100], "settle"),
                                  (t + 60, [380, 380, 100], "hold"), (op, [100, 100, 100])),
                           o=anim((0, 0, "hold"), (t, 90, "settle"), (t + 60, 0, "hold"), (op, 0))))
    LOOP_FROM["ripple"] = 0
    return doc("Ripple", 128, 128, op, rings + [dot])


def ekadashi_timeline():
    """How each tradition picks the fast day. Labels are drawn by Flutter on
    top (the widget knows the same coordinates: see tradition_explainer.dart).

    Day 1 sunrise x=130, Day 2 sunrise x=290, dawn (arunodaya, 96 min before
    sunrise) x=104. Dashami ends at x=114: after dawn, before sunrise. So
    Smarta keeps Day 1 (Ekadashi at sunrise); Vaishnava sees Dashami at dawn
    and keeps Day 2.
    """
    op = 420
    W, base = 360, 92
    out = 380  # everything fades for the loop seam
    fade = anim((0, 0, "settle"), (16, 100, "hold"), (out, 100, "exit"), (op - 4, 0))
    sr1, sr2, dawn, d_end, e_end = 130, 290, 104, 114, 262

    def band(x0, x1, c, t0, o=100):
        return layer(f"band{x0}", [group([rect((x0 + x1) / 2, 34, x1 - x0, 10, 5), fill(c, o)],
                                         p=(x0, 0), a=(x0, 0),
                                         s=anim((t0, [0, 100], "settle"), (t0 + 40, [100, 100])))],
                     o=fade)

    axis = layer("axis", [group([line((8, base), (W - 8, base)),
                                 trim(draw_on(0, 36)), stroke("faint", 2)])], o=fade)

    def sunrise(x, t0):
        arc = bez((x - 16, base), ((x - 16, base - 21), (x + 16, base - 21), (x + 16, base)))
        rays = [line((x, base - 21), (x, base - 28)),
                line((x - 17, base - 13), (x - 23, base - 18)),
                line((x + 17, base - 13), (x + 23, base - 18))]
        sun = group([arc, fill("marigold", 85)])
        r = group(rays + [stroke("marigold", 2.5)])
        return layer(f"sun{x}", [r, sun], p=st([x, base, 0]), a=(x, base),
                     s=anim((t0, [0, 0, 100], "pop"), (t0 + 30, [100, 100, 100])), o=fade)

    def guide(x, c, t0):
        return layer(f"guide{x}", [group([line((x, 44), (x, 176)), stroke(c, 1.5, o=55, dash=(3, 5))])],
                     o=anim((t0, 0, "settle"), (t0 + 20, 100, "hold"), (out, 100, "exit"), (op - 4, 0)))

    # Smarta lamp: lands on Day 1.
    smarta = layer("smarta", small_diya(0, 0, "marigold", 150, op, w=28),
                   p=anim((128, [sr1, 112, 0], "settle"), (156, [sr1, 136, 0])),
                   o=anim((0, 0, "hold"), (128, 0, "settle"), (140, 100, "hold"), (out, 100, "exit"),
                          (op - 4, 0)))
    # Vaishnava lamp: starts at dawn, meets Dashami, walks to Day 2.
    vaish = layer("vaishnava", small_diya(0, 0, "rose", 196, op, w=28),
                  p=anim((176, [dawn, 168, 0], "hold"), (236, [dawn, 168, 0], "travel"),
                         (296, [sr2, 168, 0])),
                  o=anim((0, 0, "hold"), (176, 0, "settle"), (190, 100, "hold"), (out, 100, "exit"),
                         (op - 4, 0)))
    # Dashami still there at dawn: a soft pulse where the dawn line meets it.
    touch = layer("touch", [group([ellipse(dawn, 34, 16), fill("rose", 70)])],
                  p=st([dawn, 34, 0]), a=(dawn, 34),
                  s=anim((200, [40, 40, 100], "settle"), (222, [150, 150, 100])),
                  o=anim((0, 0, "hold"), (200, 0, "settle"), (208, 100, "settle"), (236, 0, "hold"), (op, 0)))
    LOOP_FROM["ekadashi_timeline"] = 0
    return doc("Ekadashi: two rules", W, 180, op, [
        touch, smarta, vaish, sunrise(sr1, 40), sunrise(sr2, 52), guide(dawn, "rose", 170),
        guide(sr1, "marigold", 70), guide(sr2, "marigold", 82),
        band(8, d_end, "faint", 60, 70), band(d_end + 2, e_end, "gold", 74),
        band(e_end + 2, W - 8, "faint", 88, 70), axis,
    ])


SCENES = {
    "hour_diya": hour_diya,
    "two_paths": two_paths,
    "city_sun": city_sun,
    "lotus_safe": lotus_safe,
    "trishul": trishul,
    "gada": gada,
    "chakra": chakra,
    "shani_lamp": shani_lamp,
    "moon": moon,
    "bell": bell,
    "ripple": ripple,
    "ekadashi_timeline": ekadashi_timeline,
}


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, fn in SCENES.items():
        d = fn()
        with open(os.path.join(OUT, name + ".json"), "w") as f:
            json.dump(d, f, separators=(",", ":"))
    # Settled frame (as a fraction) per file, for the Dart side.
    for name, fn in SCENES.items():
        d = json.load(open(os.path.join(OUT, name + ".json")))
        print(f"{name}: op={d['op']} loopFrom={LOOP_FROM[name]} "
              f"({LOOP_FROM[name] / d['op']:.3f}) size={os.path.getsize(os.path.join(OUT, name + '.json'))}")


if __name__ == "__main__":
    main()
