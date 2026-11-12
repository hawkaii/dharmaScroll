# Verse explanation sheet

Opens from the lamp beside each verse on the Hear scroll, and from
"Explain this verse" on a kept verse. Five tabs: In simple words, Word by word,
The moment, Related verses, For my day. Listen (hold) and Share sit at the bottom.

| File | Job |
|---|---|
| `verse_notes.dart` | Model and loader for `assets/data/gita_explain_v1.json` |
| `verse_explainer.dart` | The AI seam: `VerseExplainer`, `OfflineExplainer`, `GuardedExplainer`, `acceptReflection` |
| `explain_sheet.dart` | The sheet and the "Explain this verse" link |
| `explain_motion.dart` | Lottie headers (frame 0 under reduce motion) and the word reveal |

## Content

All notes are written for this app and are a **draft, pending scholar review**.
Edit the text files in `tools/explain_gen/src/`, then run
`python3 tools/explain_gen/build.py` (and `--check` to confirm the asset is
current). Related verses are computed there from shared situation tags.
The Lottie files come from `python3 tools/explain_gen/lottie_gen.py`.

## Plugging in a model later

Scripture is never taken from a model. The sheet renders every verse, meaning
and word gloss from local data only. A model may return only a short reflection
(two sentences, at most 280 characters) and verse ids from the app's own list.

1. Write a class that implements `VerseExplainer`, for example
   `ProxyExplainer`, whose `explainForMyDay` sends the verse id, the local
   meaning and context, and the reader's one line to your server, and returns
   `DayReflection(text: ..., refs: [...])`. Set `usesModel` to `true`.
   Keep keys on the server, never in the app.
2. In `verseExplainerProvider` (bottom of `verse_explainer.dart`) return
   `GuardedExplainer(model: ProxyExplainer(...), offline: offline)`.

`GuardedExplainer` already:

- skips the model for verses flagged `personal_advice_ok: false`;
- drops any reply with Devanagari, IAST, quotation marks, an unknown verse id,
  a verse number it does not list in `refs`, or more than 280 characters
  (`acceptReflection`);
- falls back to `OfflineExplainer` on any error or after 8 seconds.

The sheet runs the on-device crisis gate (`isCrisis`) before any explainer is
called and goes straight to the crisis screen on a match. Add the server-side
checks from `docs/ai/AI_PLAN.md` sections 5 and 6 (risk flag, topic limits,
red-team prompts) in the proxy, not here.
