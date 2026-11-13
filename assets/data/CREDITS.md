# Verse data: sources and licences

File: `gita_v1.json` (version 1). 108 verses of the Bhagavad Gita.

Status of all meanings and tags: **draft, pending scholar review.**
Do not present them as authoritative until a scholar has signed them off.

## Sanskrit text

The Sanskrit of the Bhagavad Gita is ancient and in the public domain.
The text was copied from two open digital editions and compared verse by verse:

- `gita/gita` data (github.com/gita/gita), released under the Unlicense (public domain).
  Only the Devanagari verse text was used.
- The Bhagavad Gita API data (vedicscriptures.github.io), verse text only.

Where they differ in spelling, the form used in common printed editions is kept
(for example `सञ्जायते`, and sandhi-joined `सत्त्वसंशुद्धिर्ज्ञानयोग…` in 16.1).
A random sample of 20 verses was also checked against the Sanskrit Wikisource
copy of the Bhishma Parva. Wikisource has a few typing slips of its own; they were not copied.

## What was NOT used

Word-by-word meanings and transliteration in those datasets come from modern
authors and are copyrighted, so they were left out.
Nothing from Sivananda, Prabhupada / ISKCON / BBT, Chinmayananda,
Gita Press or any other copyrighted translation or commentary was used.

## Transliteration (IAST)

Generated from the Devanagari by a script written for this project (standard IAST).
Compound words stay joined as printed, so it is a reading aid, not a word split.

## English and Hindi meanings

Written fresh for this app in plain, modern language, as short paraphrases.
No translation was copied. Only public-domain English works
(Telang 1882, Arnold 1885, Besant 1905, Purohit Swami 1935) are allowed as
references for future edits.

## Situation tags and advice flag

Tags come from a fixed list of 45 emotions and situations (the `tags` key in the file).
`personal_advice_ok` is `false` for war passages, varna passages and verses that are
easy to misread. These verses must not be shown as advice for a person's own problem.

## Study notes (`gita_explain_v1.json`)

Built by `tools/explain_gen/build.py` from the hand-written notes in
`tools/explain_gen/src/`. Status: **draft, pending scholar review.**

- Simple meanings (English and Hindi), chapter context lines and "who speaks"
  lines were written fresh for this app in plain words. No translation or
  commentary was copied.
- Word-by-word glosses were made from the Sanskrit itself (sandhi split by
  hand, Devanagari generated from the IAST by `tools/explain_gen/iast.py`).
  Only the public-domain works above (Telang, Arnold, Besant, Purohit Swami)
  may be used as references.
- Related verses are computed from shared situation tags.
