"""Writes the explain sheet's Lottie files to assets/lottie/explain/.

    python3 tools/explain_gen/lottie_gen.py

Hand-built from the app's own line icons (assets/svg/icons) and board v3
colours. Only shape layers, fills, strokes, trim paths and transforms: no
masks, mattes, effects, expressions or gradients, so Flutter's `lottie`
package and Skottie draw them the same. Frame 0 of every file is a finished
still, because reduce-motion shows frame 0.
"""

import json
import math
import pathlib
import random
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/lottie/explain"


def hex_rgb(h):
    h = h.lstrip("#")
    return [round(int(h[i:i + 2], 16) / 255, 3) for i in (0, 2, 4)] + [1]


# Board v3 tokens (lib/design/tokens.dart).
MARIGOLD = hex_rgb("FFC247")
GOLD = hex_rgb("F7D58B")
SAFFRON = hex_rgb("F28C28")
ROSE = hex_rgb("E58BA3")
PEACOCK = hex_rgb("4FB3AB")
INK = hex_rgb("FBEFD9")
MUTE = hex_rgb("C9B2B8")
FAINT = hex_rgb("8F7A8C")
BG = hex_rgb("1A0F24")
SURFACE = hex_rgb("2A1A38")
FLAME = hex_rgb("FFB03B")
FLAME_CORE = hex_rgb("FFF3CF")

# Easing anchors (motion-taste.md), as (x1, y1, x2, y2).
SETTLE = (0.0, 0.65, 0.51, 0.99)
TRAVEL = (0.42, 0.0, 0.58, 1.0)  # easeInOut, for loops
ENTER = (0.20, 0.75, 0.34, 0.94)
SPRING = (0.22, 1.2, 0.36, 1.0)  # Motion.spring
LINEAR = (0.0, 0.0, 1.0, 1.0)


def st(v):
    return {"a": 0, "k": v}


def kf(*frames):
    """frames: (t, value, ease) ... ; ease applies from that frame to the next."""
    out = []
    for n, f in enumerate(frames):
        t, v = f[0], f[1]
        k = {"t": t, "s": v if isinstance(v, list) else [v]}
        if n < len(frames) - 1:
            e = f[2] if len(f) > 2 else SETTLE
            k["o"] = {"x": [e[0]], "y": [e[1]]}
            k["i"] = {"x": [e[2]], "y": [e[3]]}
        out.append(k)
    return {"a": 1, "k": out}


def tr(p=(0, 0), a=(0, 0), s=100, r=0, o=100):
    def wrap(v, pair):
        if isinstance(v, dict):
            return v
        return st(list(v) if pair else v)
    sv = s if isinstance(s, dict) else st([s, s] if not isinstance(s, (list, tuple)) else list(s))
    if sv.get("a") == 1:
        # Scale is a 2D value: a scalar keyframe [84] becomes [84, 84].
        for k in sv["k"]:
            if len(k["s"]) == 1:
                k["s"] = k["s"] * 2
    return {"ty": "tr", "p": wrap(p, True), "a": wrap(a, True), "s": sv,
            "r": wrap(r, False), "o": wrap(o, False)}


def group(items, **t):
    return {"ty": "gr", "it": items + [tr(**t)]}


def fill(c, o=100):
    return {"ty": "fl", "c": st(c), "o": o if isinstance(o, dict) else st(o), "r": 1}


def stroke(c, w=2, o=100):
    return {"ty": "st", "c": st(c), "o": o if isinstance(o, dict) else st(o),
            "w": st(w), "lc": 2, "lj": 2}


def trim(e):
    return {"ty": "tm", "s": st(0), "e": e if isinstance(e, dict) else st(e), "o": st(0), "m": 1}


def ellipse(cx, cy, w, h):
    return {"ty": "el", "p": st([cx, cy]), "s": st([w, h])}


def rect(cx, cy, w, h, r=0):
    return {"ty": "rc", "p": st([cx, cy]), "s": st([w, h]), "r": st(r)}


def shape(v, i=None, o=None, closed=False):
    z = [[0, 0]] * len(v)
    return {"ty": "sh", "ks": st({"v": v, "i": i or z, "o": o or z, "c": closed})}


def line(x1, y1, x2, y2):
    return shape([[x1, y1], [x2, y2]])


def svg_path(d):
    """SVG path data (M L H V C S Z, absolute or relative) to Lottie shapes."""
    toks = re.findall(r"[MLHVCSZmlhvcsz]|-?(?:\d+\.?\d*|\.\d+)", d)
    shapes, cur = [], None
    x = y = 0.0
    last_c2 = None
    cmd = None
    k = 0

    def num():
        nonlocal k
        v = float(toks[k])
        k += 1
        return v

    def start(px, py):
        nonlocal cur
        cur = {"v": [[px, py]], "i": [[0, 0]], "o": [[0, 0]], "c": False}
        shapes.append(cur)

    def to(px, py, c1=None, c2=None):
        cur["o"][-1] = [c1[0] - cur["v"][-1][0], c1[1] - cur["v"][-1][1]] if c1 else cur["o"][-1]
        cur["v"].append([px, py])
        cur["i"].append([c2[0] - px, c2[1] - py] if c2 else [0, 0])
        cur["o"].append([0, 0])

    while k < len(toks):
        if re.match(r"[A-Za-z]", toks[k]):
            cmd = toks[k]
            k += 1
        rel = cmd.islower()
        c = cmd.upper()
        if c == "Z":
            if cur["v"][0] == cur["v"][-1] and len(cur["v"]) > 1:
                cur["i"][0] = cur["i"].pop()
                cur["v"].pop()
                cur["o"].pop()
            cur["c"] = True
            x, y = cur["v"][0]
            last_c2 = None
            continue
        if c == "M":
            nx, ny = num(), num()
            x, y = (x + nx, y + ny) if rel else (nx, ny)
            start(x, y)
            cmd = "l" if rel else "L"
            last_c2 = None
        elif c in "LHV":
            if c == "L":
                nx, ny = num(), num()
                nx, ny = (x + nx, y + ny) if rel else (nx, ny)
            elif c == "H":
                nx = num()
                nx, ny = (x + nx if rel else nx), y
            else:
                ny = num()
                nx, ny = x, (y + ny if rel else ny)
            to(nx, ny)
            x, y = nx, ny
            last_c2 = None
        elif c in "CS":
            if c == "C":
                c1 = [num(), num()]
                if rel:
                    c1 = [x + c1[0], y + c1[1]]
            else:
                c1 = [2 * x - last_c2[0], 2 * y - last_c2[1]] if last_c2 else [x, y]
            c2 = [num(), num()]
            p = [num(), num()]
            if rel:
                c2 = [x + c2[0], y + c2[1]]
                p = [x + p[0], y + p[1]]
            to(p[0], p[1], c1, c2)
            x, y = p
            last_c2 = c2
    return [{"ty": "sh", "ks": st(s)} for s in shapes]


def layer(name, shapes, ip=0, op=None, ks=None):
    return {"ty": 4, "nm": name, "ip": ip, "op": op, "st": 0, "sr": 1, "ao": 0,
            "ks": ks or {"o": st(100), "r": st(0), "p": st([0, 0, 0]),
                         "a": st([0, 0, 0]), "s": st([100, 100, 100])},
            "shapes": shapes}


def comp(name, w, h, fr, op, layers):
    for l in layers:
        l["op"] = op
    return {"v": "5.7.0", "nm": name, "fr": fr, "ip": 0, "op": op, "w": w, "h": h,
            "ddd": 0, "assets": [], "layers": layers}


# ---------------------------------------------------------------- lamp (2.6 s loop)

def lamp():
    op = 78
    flame = group(
        [group(svg_path("M32 20c3 4 3 7 0 10-3-3-3-6 0-10z") + [fill(FLAME_CORE)]),
         group(svg_path("M32 8c8 9 8 17 0 24-8-7-8-15 0-24z") + [stroke(MARIGOLD, 2.2), fill(FLAME, 85)])],
        p=(32, 32), a=(32, 32),
        r=kf((0, -1.5, TRAVEL), (39, 1.5, TRAVEL), (78, -1.5)),
        s=kf((0, [100, 100], TRAVEL), (26, [97, 106], TRAVEL), (52, [102, 97], TRAVEL), (78, [100, 100])),
    )
    glow = group([group([ellipse(32, 21, 18, 24), fill(FLAME, 60)]),
                  group([ellipse(32, 21, 26, 32), fill(FLAME, 35)])],
                 o=kf((0, 30, TRAVEL), (39, 55, TRAVEL), (78, 30)))
    bowl = group(svg_path("M8 38h48c0 10-10 18-24 18S8 48 8 38z") + [stroke(MARIGOLD, 2.2), fill(SAFFRON, 14)])
    rim = group(svg_path("M18 46c4 2 9 3 14 3") + [stroke(MARIGOLD, 1.4, 50)])
    return comp("explain lamp", 64, 64, 30, op,
                [layer("flame", [flame]), layer("bowl", [rim, bowl]), layer("glow", [glow])])


# ---------------------------------------------------------------- lotus (opens once)

def lotus():
    op = 48
    base = (32, 52)
    def petal(d, r0, delay):
        return group(svg_path(d) + [stroke(MARIGOLD, 2.1), fill(GOLD, 12)],
                     p=base, a=base,
                     r=kf((delay, r0, SPRING), (delay + 26, 0)),
                     s=kf((delay, 82, SPRING), (delay + 26, 100)))
    left = petal("M32 52C20 50 11 41 8 26c10 1 19 8 24 26z", 30, 6)
    right = petal("M32 52c12-2 21-11 24-26-10 1-19 8-24 26z", -30, 9)
    centre = group(svg_path("M32 52C23 44 23 26 32 10c9 16 9 34 0 42z") + [stroke(MARIGOLD, 2.1), fill(ROSE, 18)],
                   p=base, a=base, s=kf((0, [92, 92], SPRING), (24, [100, 100])))
    water = group(svg_path("M8 40c6 8 14 12 24 12s18-4 24-12") +
                  [trim(kf((14, 0, ENTER), (40, 100))), stroke(MARIGOLD, 1.5, 55)])
    return comp("explain lotus", 64, 64, 30, op,
                [layer("centre", [centre]), layer("sides", [left, right]), layer("water", [water])])


# ---------------------------------------------------------------- feather (3.6 s sway)

def feather():
    op = 108
    eye = []
    for rx, ry, items in ((11, 15, [stroke(MARIGOLD, 2), fill(PEACOCK, 22)]),
                          (5.5, 8.5, [stroke(PEACOCK, 2), fill(BG, 40)])):
        eye.append(group([ellipse(0, 0, rx * 2, ry * 2)] + items, p=(39, 24), r=22))
    core = group([ellipse(0, 0, 3.6, 6), fill(MARIGOLD)], p=(39, 24), r=22,
                 s=kf((0, 100, TRAVEL), (54, 118, TRAVEL), (108, 100)))
    # The quill stops at the eye's rim so it never shows through the eye.
    quill = group(svg_path("M22 60C25 46 30 34 38 16") + [trim(74), stroke(MARIGOLD, 2)])
    barbs = group(svg_path("M29 38c-5-1-9 1-12 4M31 46c-4-1-7 0-10 3M30 30c-4-3-8-3-12-1") +
                  [stroke(MARIGOLD, 1.4, 60)])
    whole = group([core, eye[1], eye[0], barbs, quill],
                  p=(22, 60), a=(22, 60),
                  r=kf((0, -3, TRAVEL), (54, 3, TRAVEL), (108, -3)))
    return comp("explain feather", 64, 64, 30, op, [layer("feather", [whole])])


# ---------------------------------------------------------------- path (lights once)

def path():
    op = 54
    stones = [(12, 44), (32, 24), (52, 40)]
    route = svg_path("M12 44C18 32 24 26 32 24S48 30 52 40")
    lit = group(route + [trim(kf((0, 0, TRAVEL), (36, 100))), stroke(MARIGOLD, 2)])
    dim = group(svg_path("M12 44C18 32 24 26 32 24S48 30 52 40") + [stroke(FAINT, 1.4, 70)])
    out = []
    for n, (x, y) in enumerate(stones):
        # The first stone is lit from frame 0, so the still reads "start here".
        at = (0, 18, 34)[n]
        on = st(100) if at == 0 else kf((at, 0, ENTER), (at + 6, 100))
        out.append(group([group([ellipse(0, 0, 4, 4), fill(MARIGOLD)]),
                          group([ellipse(0, 0, 11, 11), stroke(MARIGOLD, 2), fill(MARIGOLD, 30)])],
                         p=(x, y), o=on,
                         s=st([100, 100]) if at == 0 else kf((at, 84, SPRING), (at + 14, 100))))
        out.append(group([ellipse(0, 0, 11, 11), stroke(FAINT, 1.6), fill(SURFACE)], p=(x, y)))
    return comp("explain path", 64, 64, 30, op,
                [layer("stones", out[0::2]), layer("stones dim", out[1::2]),
                 layer("route lit", [lit]), layer("route", [dim])])


# ---------------------------------------------------------------- the moment (5 s, once)

def moment():
    w, h, op = 320, 180, 150
    horizon = 140
    rnd = random.Random(47)

    def army(x0, x1, facing):
        back, front = [], []
        for row, (scale, out) in enumerate(((0.75, back), (1.0, front))):
            x = x0 + row * 6
            while x < x1:
                ph = (16 + rnd.random() * 10) * scale
                base = horizon if row else horizon - 4
                fw, fh = 8 * scale, 5 * scale
                out.append(line(x, base, x, base - ph))
                out.append(shape([[x, base - ph], [x + facing * fw, base - ph + fh / 2], [x, base - ph + fh]],
                                 closed=True))
                x += 11 + rnd.random() * 5
        return [group(front + [stroke(MUTE, 1.4, 60), fill(MUTE, 45)]),
                group(back + [stroke(FAINT, 1.2, 50), fill(FAINT, 35)])]

    sky = layer("sky", [group([rect(w / 2, h / 2, w, h), fill(BG)])])
    # Dawn: stacked faint ellipses fake a soft gradient (no gradient fills).
    dawn = layer("dawn", [
        group([ellipse(160, 146, 120 + 70 * n, 50 + 26 * n), fill(SAFFRON if n < 2 else ROSE, 7)],
              o=kf((0, 0, TRAVEL), (60 + 8 * n, 100)))
        for n in range(4)
    ])
    stars = []
    for _ in range(9):
        sx, sy = 20 + rnd.random() * 280, 12 + rnd.random() * 70
        if 120 < sx < 200 and sy < 80:
            sx += 90
        stars.append(group([ellipse(sx, sy, 2, 2), fill(INK)]))
    star_l = layer("stars", [group(stars, o=kf((0, 70, TRAVEL), (60, 0)))])
    sun = layer("sun", [
        group([ellipse(0, 0, 84, 84), fill(SAFFRON, 14)], p=kf((10, [160, 158], TRAVEL), (80, [160, 136]))),
        group([ellipse(0, 0, 46, 46), fill(SAFFRON, 72)], p=kf((10, [160, 158], TRAVEL), (80, [160, 136]))),
    ], ks={"o": kf((6, 0, TRAVEL), (60, 100)), "r": st(0), "p": st([0, 0, 0]),
           "a": st([0, 0, 0]), "s": st([100, 100, 100])})
    # The ground is the sky's colour: the sheet behind the card is SURFACE,
    # so a SURFACE ground would vanish into it.
    ground = layer("ground", [
        group([line(0, horizon, w, horizon), stroke(INK, 1, 20)]),
        group([rect(w / 2, (horizon + h) / 2 + 0.5, w, h - horizon), fill(BG)]),
    ])
    armies = layer("armies", army(18, 112, 1) + army(210, 304, -1))

    # Chariot, side view, facing left: car, shaft, standard and pennant, with
    # the wheel drawn in front so every spoke shows. The wheel rests on the
    # horizon.
    hub = (152, 127)
    spokes = [line(hub[0], hub[1], hub[0] + 12 * math.cos(i * math.pi / 3),
                   hub[1] + 12 * math.sin(i * math.pi / 3)) for i in range(6)]
    chariot = [
        group([shape([[134, 106], [188, 106], [181, 122], [141, 122]], closed=True),
               stroke(GOLD, 2), fill(SURFACE)]),
        group([shape([[138, 118], [110, 126]]), stroke(GOLD, 2)]),
        group([line(178, 106, 178, 76), stroke(GOLD, 1.6)]),
        group([shape([[178, 76], [194, 80], [178, 85]], closed=True), fill(SAFFRON), stroke(SAFFRON, 1)],
              p=(178, 76), a=(178, 76),
              s=kf((0, [100, 100], TRAVEL), (25, [84, 100], TRAVEL), (50, [100, 100], TRAVEL),
                   (75, [86, 100], TRAVEL), (100, [100, 100], TRAVEL), (125, [85, 100], TRAVEL), (150, [100, 100]))),
        group([ellipse(hub[0], hub[1], 26, 26), stroke(GOLD, 2), fill(BG, 80)]),
        group(spokes + [stroke(GOLD, 1.2, 80)]),
        group([ellipse(hub[0], hub[1], 4, 4), fill(GOLD)]),
    ]
    car = layer("chariot", chariot[::-1])

    conch_shapes = svg_path("M10 40c0-15 11-27 27-28 9-1 15 4 15 11 0 7-6 11-12 10-5-1-8-5-6-9") + \
        svg_path("M10 40c0 9 7 15 17 15 15 0 26-10 29-27")
    lines = svg_path("M20 24c-5 4-8 9-8 15M28 20c-6 4-10 10-11 18M38 19c-5 3-9 8-11 15")
    tip = svg_path("M52 23c3-4 5-8 4-13")
    conch = layer("conch", [group(
        [group(lines + [stroke(MARIGOLD, 1.5, 60)]), group(tip + [stroke(MARIGOLD, 2.1, 70)]),
         group(conch_shapes + [stroke(MARIGOLD, 2.4), fill(GOLD, 16)])],
        p=kf((80, [160, 66], ENTER), (110, [160, 52])), a=(33, 34), s=58,
        r=kf((80, -10, SETTLE), (112, 0)),
        o=kf((80, 0, ENTER), (100, 100)))])
    rings = []
    for n, at in enumerate((100, 112, 124)):
        rings.append(group([ellipse(0, 0, 40, 40), stroke(GOLD, 1.4)],
                           p=(160, 52),
                           s=kf((at, 70, SETTLE), (at + 26, 190)),
                           o=kf((at, 0, LINEAR), (at + 4, 60, SETTLE), (at + 26, 0))))
    ring_l = layer("rings", rings)
    return comp("explain moment", w, h, 30, op,
                [ring_l, conch, car, armies, ground, sun, star_l, dawn, sky])


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, fn in (("lamp", lamp), ("lotus", lotus), ("feather", feather),
                     ("path", path), ("moment", moment)):
        p = OUT / f"{name}.json"
        p.write_text(json.dumps(fn(), separators=(",", ":")) + "\n")
        print(f"{p.relative_to(ROOT)}  {p.stat().st_size} bytes")


if __name__ == "__main__":
    main()
