"""IAST to Devanagari, for the word-by-word chips.

The verse file's IAST was generated from the Devanagari, so this is checked by
round-tripping every line of `assets/data/gita_v1.json` (see `build.py --check`).
"""

import unicodedata

VOWELS = [
    ("ai", "ऐ", "ै"), ("au", "औ", "ौ"),
    ("ā", "आ", "ा"), ("ī", "ई", "ी"), ("ū", "ऊ", "ू"),
    ("ṝ", "ॠ", "ॄ"), ("ṛ", "ऋ", "ृ"), ("ḷ", "ऌ", "ॢ"),
    ("a", "अ", ""), ("i", "इ", "ि"), ("u", "उ", "ु"),
    ("e", "ए", "े"), ("o", "ओ", "ो"),
]

CONSONANTS = [
    ("kh", "ख"), ("gh", "घ"), ("ch", "छ"), ("jh", "झ"), ("ṭh", "ठ"),
    ("ḍh", "ढ"), ("th", "थ"), ("dh", "ध"), ("ph", "फ"), ("bh", "भ"),
    ("k", "क"), ("g", "ग"), ("ṅ", "ङ"), ("c", "च"), ("j", "ज"), ("ñ", "ञ"),
    ("ṭ", "ट"), ("ḍ", "ड"), ("ṇ", "ण"), ("t", "त"), ("d", "द"), ("n", "न"),
    ("p", "प"), ("b", "ब"), ("m", "म"), ("y", "य"), ("r", "र"), ("l", "ल"),
    ("v", "व"), ("ś", "श"), ("ṣ", "ष"), ("s", "स"), ("h", "ह"),
]

MARKS = [("m̐", "ँ"), ("ṁ", "ं"), ("ṃ", "ं"), ("ḥ", "ः"), ("'", "ऽ")]

VIRAMA = "्"


def _match(s, i, table):
    for entry in table:
        if s.startswith(entry[0], i):
            return entry
    return None


def to_deva(text):
    s = unicodedata.normalize("NFC", text.lower())
    out = []
    i = 0
    pending = False  # last output is a bare consonant waiting for a vowel
    while i < len(s):
        m = _match(s, i, MARKS)
        if m:
            if pending:
                out.append(VIRAMA)
                pending = False
            out.append(m[1])
            i += len(m[0])
            continue
        c = _match(s, i, CONSONANTS)
        if c:
            if pending:
                out.append(VIRAMA)
            out.append(c[1])
            pending = True
            i += len(c[0])
            continue
        v = _match(s, i, VOWELS)
        if v:
            out.append(v[2] if pending else v[1])
            pending = False
            i += len(v[0])
            continue
        if pending:
            out.append(VIRAMA)
            pending = False
        out.append(s[i])
        i += 1
    if pending:
        out.append(VIRAMA)
    return "".join(out)
