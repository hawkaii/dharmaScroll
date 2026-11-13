"""Builds assets/data/gita_explain_v1.json from the hand-written notes in src/.

    python3 tools/explain_gen/build.py          # write the asset
    python3 tools/explain_gen/build.py --check  # fail if the asset is stale

Everything in src/ is written for this app. Draft, pending scholar review.
Related verses are computed here from shared situation tags, so they stay in
step with the tags in gita_v1.json.
"""

import json
import pathlib
import re
import sys

from iast import to_deva

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[1]
VERSES = ROOT / "assets/data/gita_v1.json"
OUT = ROOT / "assets/data/gita_explain_v1.json"
RELATED = 3


def parse(text):
    blocks = {}
    chapters = {}
    cur = None
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("@ch "):
            cur = chapters.setdefault(line[4:].strip(), {})
            continue
        if line.startswith("@"):
            cur = blocks.setdefault(line[1:].strip(), {})
            continue
        key, _, value = line.partition(":")
        if cur is None or not _:
            raise SystemExit(f"bad line: {raw!r}")
        cur[key.strip()] = value.strip()
    return blocks, chapters


def words(spec, vid):
    out = []
    for part in spec.split("|"):
        iast, sep, meaning = part.partition("=")
        iast, meaning = iast.strip(), meaning.strip()
        if not sep or not iast or not meaning:
            raise SystemExit(f"{vid}: bad word {part!r}")
        deva = "-".join(to_deva(seg) for seg in iast.split("-"))
        out.append([deva, iast, meaning])
    return out


def related(v, verses):
    tags = set(v["tags"])
    scored = []
    for order, u in enumerate(verses):
        if u["id"] == v["id"]:
            continue
        shared = len(tags & set(u["tags"]))
        if shared:
            scored.append((-shared, u["chapter"] != v["chapter"], order, u["id"], shared))
    scored.sort()
    strong = [s for s in scored if s[4] >= 2]
    pick = (strong + [s for s in scored if s[4] < 2])[:RELATED]
    return [s[3] for s in pick]


def build():
    verses = json.loads(VERSES.read_text())["verses"]
    notes, chapters = {}, {}
    for f in sorted((HERE / "src").glob("*.txt")):
        b, c = parse(f.read_text())
        dup = notes.keys() & b.keys()
        if dup:
            raise SystemExit(f"duplicate notes: {sorted(dup)}")
        notes.update(b)
        chapters.update(c)
    ids = [v["id"] for v in verses]
    missing = [i for i in ids if i not in notes]
    extra = [i for i in notes if i not in ids]
    if missing or extra:
        raise SystemExit(f"missing {missing} extra {extra}")
    out_verses = {}
    for v in verses:
        n = notes[v["id"]]
        for k in ("en", "hi", "w"):
            if not n.get(k):
                raise SystemExit(f"{v['id']}: no {k}")
        entry = {
            "simple_en": n["en"],
            "simple_hi": n["hi"],
            "words": words(n["w"], v["id"]),
            "related": related(v, verses),
        }
        if "moment" in n:
            entry["moment_en"] = n["moment"]
            entry["moment_hi"] = n["moment_hi"]
        out_verses[v["id"]] = entry
    doc = {
        "version": 1,
        "status": "draft, pending scholar review",
        "chapters": {
            k: {"context_en": c["en"], "context_hi": c["hi"]}
            for k, c in sorted(chapters.items(), key=lambda kv: int(kv[0]))
        },
        "verses": out_verses,
    }
    return json.dumps(doc, ensure_ascii=False, indent=1) + "\n"


def check_iast():
    bad = 0
    for v in json.loads(VERSES.read_text())["verses"]:
        for s, t in zip(v["sanskrit"], v["iast"]):
            if re.sub(r"[।॥\s]", "", s) != re.sub(r"\s", "", to_deva(t)):
                bad += 1
                print(f"iast round trip differs: {v['id']}: {t}")
    return bad


if __name__ == "__main__":
    text = build()
    if "--check" in sys.argv:
        if check_iast() or OUT.read_text() != text:
            raise SystemExit("gita_explain_v1.json is stale or the converter drifted")
        print("ok")
    else:
        OUT.write_text(text)
        print(f"wrote {OUT.relative_to(ROOT)}")
