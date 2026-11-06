# DharmaScroll — Design & Build Specification

**Version 1.0 · 6 November 2026**
**Branch:** `docs/week-1-execution-plan`
**Scope:** the week-1 Flutter MVP — onboarding, shloka feed, expand sheet, checkpoints, Moksh Points, Gita Yatra (Ch 1–3), Daily Sankalp, Mann Darpan v0, share cards, profile.

**The PDF and the HTML are the source. This document is a derivative that fills gaps.**

The hierarchy is fixed:

1. **`DharmaScroll_Product_Blueprint.pdf` owns roles and semantics** — what a colour *means*, which type voice exists, what each screen contains, what the copy says.
2. **`dharmascroll-site.html` owns finish and physics** — the exact hexes, border widths, shadow offsets, radii, and the pixel-level look of all 24 wireframes.
3. **`WEEK_1_EXECUTION_PLAN.md` owns scope** — what ships this week and what waits.
4. **This document owns only what the three above are silent on**, plus the mobile adaptations the sources cannot express because one is a print PDF and the other is a 1180 px web page.

Every place this document departs from a source is listed in §0.2 with its reason. If a departure is not in that table, it is a bug in this document, not a design decision.

---

## 0. The sources, and what each one is authoritative for

| Source | Authoritative for | Not authoritative for |
|---|---|---|
| `DharmaScroll_Product_Blueprint.pdf` | product thesis, the problem, the economy's intent, the content moat, IA, the 24 wireframes' *flows* | the visual finish — its palette is a first draft |
| `dharmascroll-site.html` | **visual energy**, component physics, interaction detail, copy voice, the 24 wireframes' *pixels* | mobile layout — it is a 1180 px marketing page |
| `WEEK_1_EXECUTION_PLAN.md` | scope, the deferred list, day order, acceptance criteria, stack choices | typography specifics (superseded, see §3.1) |
| `docs/design.md` (this file) | mobile adaptation, gaps the three are silent on, engineering | colours, copy, roles or scope the sources already fix |

### The one real conflict, and how it is resolved

The PDF asks for a **warm, restrained parchment** app. The HTML asks for a **dark-first neo-brutalist poster**. Both are right, for different surfaces.

> **The app is a book with brass fittings. The website is the poster for the book.**

Three surface classes, and every screen declares which one it is:

| Surface | Where | Physics |
|---|---|---|
| **Patra** (parchment, light) | feed, expand sheet, library, Yatra, wallet, Sankalp, profile | warm paper field, 3 dp ink border, **no shadow on full-bleed reading surfaces** |
| **Ratri** (dark room) | Mann Darpan (always), journal, crisis backdrop, share composer chrome | deep maroon field, gold type, zero paper grain |
| **Sindoor field** (vermillion authority block) | one per screen maximum: chapter header, wallet header, reward plate, streak card | vermillion fill, parchment type, gold mono eyebrow, heavy shadow |

The rule that keeps it from becoming a theme park: **one paper, one ink, one accent per screen, and at most one saturated field.** The HTML uses seven accents simultaneously because it is 1180 px wide; a 390 px phone collapses into mud.

### 0.2 Departures from the sources, and why

Nothing in this table is silent. Each row is a decision the sources do not make, or make differently.

| # | Source says | This document does | Why |
|---|---|---|---|
| 1 | PDF §10: **Kesar `#C2601C` = primary action**; HTML paints `.bt` with **Sindoor `#7A1E18`** | Buttons use Sindoor; Kesar is the accent (underline, active tab, MP numerals) | The two sources genuinely conflict on button fill. HTML owns finish, and its primary button is vermillion. Papered over as "reconciliation" in v1.0 — corrected here. |
| 2 | PDF: **Sindoor = headings and Sanskrit** | Sindoor is also the authority *field*, and the verse colour | The field use is HTML's (`.wk`/`.verse .skt` are sindoor, and `.bt` is sindoor). The verse colour is now stated explicitly, which v1.0 omitted. |
| 3 | PDF names **Tiro Sanskrit, EB Garamond, Inter, Noto Sans Devanagari** | Archivo + Instrument Sans + IBM Plex Mono + Tiro Sanskrit + Tiro Hindi + Noto Sans Devanagari | **User decision, this session.** EB Garamond's job was "headings, translations"; the PDF's three voices collapse to two because Instrument Sans covers translation and UI at phone sizes, and one fewer family is one fewer offline failure. The PDF's *voices* are preserved; only the files change. |
| 4 | HTML declares **Yatra One** first for `--skt` and uses it 3× | Cut; the ॐ is Tiro Sanskrit at 64 sp | Honest reason: one extra family for the logo only. v1.0 wrongly claimed "one glyph, ~60 KB" — the ॐ plus Latin subsets to roughly 10 KB. The cut stands on simplicity, not on a false byte count. |
| 5 | HTML `--sh: 7px 7px 0`, `4px 4px 0`, `:active` = translate(4,4) + 3px | Adopted verbatim (v1.0 had invented 5 dp/2 dp) | The prototype's "stamped plate" feel *is* the 7 px offset. Halving it was the single biggest reason v1.0's components did not look like the wireframes. |
| 6 | HTML radii: **7 px** cards/buttons, **9 px** chips/badges, **14 px** sheet, 28 px phone | Adopted (v1.0 had 4/8/20) | Same reason as #5. 4 dp reads as "slightly rounded rectangle"; 7–9 reads as a printed plate. |
| 7 | HTML `--ink2: #4B3524`, `#FFF7E6` raised blocks, `#D7C29B` dividers, `.plate.aged` three-stop ramp | Adopted those exact values (v1.0 had #5A4430, #FFFDF7, #C7AE83, a two-stop retune) | The source already had these tokens. Replacing a warm cream with near-white is why v1.0's inset blocks looked like Material cards. |
| 8 | HTML has **one** red `#B8342B` | Two roles: `dangerFill #B8342B` (button) and `danger #8E2418` (text on parchment, for 4.6:1) | One hue, two tints, because 3 dp text in `#B8342B` on cream is 4.4:1. `clay` from v1.0 is deleted — it was a third invented red. |
| 9 | HTML: 3 dp is the heaviest stroke | 4 dp for modals and the crisis card | The HTML has no modals. A 3 dp card floating over a 3 dp page needs one more step to read as above it. |
| 10 | HTML: shadows on nearly every card | `e0` (no shadow) on feed cards, list rows, sheet interiors | A shadow on every element at phone scale looks like stickers. This is the one editorial call kept from v1.0, and it is deliberate. |
| 11 | PDF §10: shloka **24–28 pt** | 28 feed, 24 lesson, **20 for word-by-word only** | 20 sp is allowed by the separate a11y line ("Sanskrit never below 20 pt"), and a gloss is not verse. The verse itself never drops below 24. |
| 12 | PDF/HTML put the meaning in **both** Hindi and English on the card | Both shown by default in Hindi and Hinglish modes; English mode leads with English | v1.0 treated "Hindi + English" as an opt-in mode. It is the source's default card content. |
| 13 | PDF §04: long-press = share; double-tap = save | Both implemented; the rail also carries an explicit Share | v1.0 dropped long-press. Gestures are additive to the rail, never a replacement for a visible control. |
| 14 | HTML: 7 px shadow and rotate(-2deg) stamps | Max 2 rotations per screen | Texture, not a system. The HTML uses rotation on four elements per section. |
| 15 | §08 economy: −10 silent Sankalp, −30 abandoned challenge, −5 quiz guessing, −2%/day decay, −50 abuse | **Week 1 ships earn-only.** No negative rules are registered; the clamp exists and is tested | The check-in and challenge flows that trigger those penalties are not in scope this week. Stated plainly instead of shipping a ledger that can go down without the rules that justify it. |
| 16 | PDF: "Searching 700 shlokas" | "Searching shlokas…" until the corpus is 700 | Week 1 ships a seed set. A string that names a count the app does not have is the same failure the doc bans in §11.10. |

### What we take from the HTML

3 dp ink borders · hard offset shadows with **zero blur** · mono stamps · letterpress "plate" logic · the aged-parchment gradient · one dominant object per screen · copy that talks like a person ("Aaj ka din kaisa tha?", "Sach bolne ke points hain. Jhooth ke nahi.").

### What we reject from the HTML

| HTML thing | Why it dies on a phone | App instead |
|---|---|---|
| `font-stretch: 125%` at 900 weight | at 390 dp a 34 pt expanded headline fits ~11 characters; Hindi overflows instantly | Archivo at **100% width** in-app; 112% for splash wordmark and reward numerals only |
| A shadow on **nearly** every element | at phone scale, a page of stickers | 7 dp **only on liftable objects**; 0 dp on feed cards, list rows, sheet interiors (§0.2 #10) |
| 3–4 column marketing grids | untappable | single column; 2-up only for stat trios and badge grids |
| Uppercase mono eyebrow on every block | six per screen is noise | **max one mono eyebrow per screen** |
| `-webkit-text-stroke` outline type | fails contrast, fails small, fails Devanagari | banned |
| Marquee ticker | steals attention from the verse | banned in-app (marketing only) |
| Hover transforms | no pointer | press-in physics only (§4.5) |
| Emoji in nav and buttons | inconsistent across Android OEMs | custom line icons; emoji only in mood chips |
| Repeated rotated stamps | charming once, chaotic ten times | **max 2 rotations per screen** |
| `#E8782A` kesar on parchment | 2.50:1 — unreadable | banned on light; light uses `#C2601C` |
| Full-saturation parchment at 1 am | painful | auto-Ratri after sunset, opt-in with a one-tap undo |

---

## 1. Design principles

1. **The verse is the interface.** Nothing competes with the Devanagari for attention — *so the header caps at 52 dp and metadata renders in muted ink, not in a saffron eyebrow on every row.*
2. **Bold at the edges, quiet in the middle.** Thick borders and hard shadows belong to frames, buttons and rewards, never to the reading surface — *so a shloka card keeps its border and drops its shadow, while the reward plate gets both.*
3. **Night is a room, not a theme.** Ratri is where the user is vulnerable or winding down — *so Mann Darpan is always dark and the feed follows the sun, instead of a global dark toggle repainting the product.*
4. **The game pays for depth, never for time.** Points fire on acts of understanding — *so the seventh swipe in four seconds gets a "slow down" card, not confetti.*
5. **Never make the user feel behind.** No countdown, no lost-streak modal, no red for absence — *so a day-10 return gets three doorways back in, not an apology screen.*

---

## 2. Colour system

### 2.1 The reconciliation rule, stated once

**The PDF palette wins every light surface. The HTML palette wins every dark surface.** Measured, not vibed: PDF kesar `#C2601C` is a deeper orange that survives on cream (3.59:1 large text), where HTML kesar `#E8782A` collapses to 2.50:1. On `#1F0F0A` the relationship inverts — `#E8782A` reaches 6.32:1 while `#C2601C` only manages 4.46:1. Same brand: aged brass in daylight, lit diya at night.

Second rule: **on parchment, gold and kesar are fields and strokes, never small text.** `#B08A2E` as text on `#FBF6EA` is 2.99:1 — a genuine failure, and the HTML's gold stamp with ink text is the correct pattern. Gold becomes a *fill* on light (5.12:1 with ink) and a *text colour* on dark (9.08:1).

### 2.2 Tokens

| Token | Patra (light) | Ratri (dark) | Role |
|---|---|---|---|
| `surfaceCanvas` | `#F5ECD9` | `#1F0F0A` | screen base |
| `surface` | `#FBF6EA` | `#2A150E` | cards, sheets |
| `surfaceRaised` | `#FFF7E6` (HTML) | `#26120C` (HTML) | nested blocks, inputs, ledger rows |
| `surfaceSunken` | `#EAD8B3` | `#150A07` | tracks, wells, disabled fills |
| `surfaceAged` | `#F6EBD2 → #E9D7B2 → #D7BE8E` radial, `.plate.aged` | `#3B1A12 → #1F0F0A` | feed art layer, share card |
| `field` | `#6E1F1A` | `#7A1E18` | Sindoor field: chapter header, wallet, rewards |
| `onField` | `#F5ECD9` | `#F5ECD9` | type inside a field |
| `ink` | `#2A1C11` | `#F3E7CF` | primary text |
| `inkMuted` | `#4B3524` (HTML `--ink2`) | `#C9B38E` | secondary text, metadata |
| `inkFaint` | `#7A6146` | `#9C8264` | timestamps, hints (≥14 sp only) |
| `inkDisabled` | `#A08A6B` | `#5C4432` | disabled labels |
| `primary` | `#6E1F1A` | `#E8782A` | primary action fill |
| `primaryPressed` | `#59160F` | `#C95F17` | pressed |
| `onPrimary` | `#F5ECD9` | `#1A0F0A` | label on primary |
| `accentKesar` | `#C2601C` | `#E8782A` | energy accent, underline, icons, MP numerals ≥20 sp |
| `gold` | `#B08A2E` | `#D9B04C` | rewards, MP, streak, Sankalp field |
| `onGold` | `#2A1C11` | `#1A0F0A` | type on gold |
| `success` | `#3F5C28` | `#9BC06A` | correct answer, kept promise |
| `successTint` | `#DCE8C8` | `#22301A` | correct row background |
| `danger` | `#8E2418` | `#E4695A` | crisis call button, destructive only |
| `dangerFill` | `#B8342B` | `#B8342B` | filled destructive button |
| ~~`clay`~~ | *removed* | *removed* | ledger negatives use `danger`; a third red was invented, not sourced |
| `border` | `#2A1C11` | `#0B0503` | the structural stroke |
| `borderQuiet` | `#D7C29B` (HTML) | `rgba(243,231,207,0.14)` | hairlines, dividers — decorative only |
| `shadow` | `#2A1C11` | `#000000` | hard offset shadow |
| `scrim` | `rgba(26,15,10,0.55)` | `rgba(0,0,0,0.68)` | behind sheets and modals |

### 2.3 Contrast (WCAG 2.2, sRGB)

| Pair | Ratio | Verdict |
|---|---|---|
| ink `#2A1C11` on Patra `#F5ECD9` | **14.05:1** | AAA body |
| ink on Card `#FBF6EA` | **15.33:1** | AAA |
| inkMuted on Patra | **7.76:1** | AAA body |
| onPrimary `#F5ECD9` on `#6E1F1A` | **9.54:1** | AAA |
| gold fill `#B08A2E` + ink | **5.12:1** | AA (Sankalp card is 17 sp semibold) |
| accentKesar `#C2601C` on Card | **3.91:1** | large text only (≥24 sp / ≥19 sp bold) |
| gold as *text* on Card | **2.99:1** | **fails — never on light** |
| HTML kesar `#E8782A` on Patra | **2.50:1** | **banned on light** |
| `#F3E7CF` on Ratri `#1F0F0A` | **15.16:1** | AAA |
| `#C9B38E` on Ratri | **9.13:1** | AAA |
| `#E8782A` on Ratri | **6.32:1** | AA+ |
| gold `#D9B04C` on Ratri | **9.08:1** | AAA |
| gold on field `#7A1E18` | **5.07:1** | AA — the MP badge |
| success `#9BC06A` on `#2A150E` | **8.37:1** | AAA |
| danger `#E4695A` on Ratri | **5.34:1** | AA |

**Hard rules.** Body copy ≥ 7:1 everywhere (achieved). No text below 4.5:1 except disabled (≥ 3:1). `clay` appears at most once per screen. `borderQuiet` is decorative and never the only indicator of a control boundary. A screen may not contain both `danger` and `gold` competing — the crisis screen has **zero** gold.

### 2.4 When each theme applies

- **Always Ratri:** Mann Darpan, journal, share composer chrome, crisis backdrop.
- **Patra, auto-switching:** feed, sheets, library, Yatra, wallet, profile. "Auto Ratri" is ON by default and switches between sunset and sunrise. The first switch shows a one-time toast with an inline undo: *"Ratri mode on, for your eyes. Band karein?"*
- **Share-card preview:** Ratri chrome regardless of time, so the parchment card pops.
- **Crisis screen:** neutral `#FBF6EA`, no brand mark, no gold, no shadow, no motion. Human help should not look designed.

---

## 3. Typography

### 3.1 Families and jobs

| Family | Job | Why |
|---|---|---|
| **Archivo** (variable, 400–900; 100% width in-app) | display, screen titles, reward numerals, level names | flat, printed quality; holds 900 without looking like a startup |
| **Instrument Sans** (400/500/600) | UI, body, buttons, English meaning | warmer than Inter, slightly narrow so Hinglish fits |
| **IBM Plex Mono** (400/500/600) | stamps, verse refs, MP numerals, timers, ledger deltas | the "printed label" voice; tabular by default |
| **Tiro Devanagari Sanskrit** | all shloka text | correct conjuncts, real danda, generous matras |
| **Tiro Devanagari Hindi** | Hindi *reading* text: meaning, Katha, Jeevan | serif warmth on parchment |
| **Noto Sans Devanagari** | Hindi *UI*: buttons, chips, labels, nav; also the Devanagari fallback | stays crisp at 12–15 sp where Tiro turns to hair |

**Deviation from the plan, on purpose.** `WEEK_1_EXECUTION_PLAN.md` names **EB Garamond** and **Inter**. This document replaces them:

- **EB Garamond → Instrument Sans.** Garamond has no Devanagari, its x-height fights Tiro Sanskrit next to it, and at 15 sp on a phone its old-style figures are unreadable in a ledger. Instrument Sans costs nothing in warmth at this size and removes a family.
- **Inter → Instrument Sans.** One family instead of two for the same job; Inter is the default-app look we are trying not to ship.
- **Add Archivo + IBM Plex Mono.** The HTML's personality lives in the display face and the mono stamp. Without them the app looks like the PDF but loses the energy the brief asks for.
- **Yatra One is cut.** It exists in the HTML for the ॐ and one wordmark. A whole family for one glyph at one size is not worth ~60 KB and a shaping bug; Tiro Sanskrit at 64 sp carries the ॐ.

Net: six families, all OFL-1.1, bundled (never fetched at runtime — see §12.5).

### 3.2 Type scale

| Token | Size / line | Weight | Tracking | Family | Use |
|---|---|---|---|---|---|
| `d1` | 40 / 44 | 900 | −0.02 em | Archivo | streak count on reward plate, chapter numeral |
| `d2` | 32 / 36 | 800 | −0.015 em | Archivo | screen-hero headlines |
| `d3` | 26 / 32 | 800 | −0.01 em | Archivo | sheet titles, wallet MP |
| `t1` | 22 / 28 | 700 | −0.005 em | Archivo | screen titles in the top bar |
| `t2` | 18 / 24 | 700 | 0 | Archivo | section headers |
| `h1` | 17 / 26 | 600 | 0 | Instrument Sans | card titles, list headers |
| `b1` | 17 / 28 | 400 | 0 | Instrument Sans | reading body (Jeevan, Katha) |
| `b2` | 16 / 24 | 400 | 0 | Instrument Sans | standard body |
| `b3` | 14 / 21 | 400 | 0 | Instrument Sans | secondary body |
| `l1` | 13 / 18 | 500 | 0.005 em | Instrument Sans | button and chip labels |
| `c1` | 12 / 16 | 400 | 0.01 em | Instrument Sans | captions, helper text |
| `m1` | 11 / 14 | 600 | **0.14 em, uppercase** | IBM Plex Mono | stamps, eyebrows, verse refs |
| `m2` | 13 / 18 | 500 | 0.02 em | IBM Plex Mono | numbers, timers, deltas (tabular) |
| `sktL` | **28 / 44** | 400 | **0** | Tiro Sanskrit | feed shloka (default) |
| `sktM` | **24 / 38** | 400 | 0 | Tiro Sanskrit | lesson player, result card |
| `sktS` | **20 / 32** | 400 | 0 | Tiro Sanskrit | word-by-word in Shabdarth — **floor, never lower** |
| `iast` | 13 / 22 | 400 italic | 0.01 em | Instrument Sans | transliteration |
| `hiRead` | 17 / 30 | 400 | 0 | Tiro Hindi | Hindi meaning paragraph |
| `hiUI` | 15 / 22 | 500 | 0 | Noto Sans Devanagari | Hindi buttons and chips |

### 3.3 Devanagari rules (non-negotiable)

- Prose line-height **1.75** (17/30). Verse **1.55** (28/44) — verse is pre-broken into padas and needs less air.
- **Zero letter-spacing on any Devanagari string.** Tracking breaks conjuncts (`क्ष`, `द्ध`, `ट्ट`) and detaches matras from their base.
- **Never italicise Devanagari.** Tiro Sanskrit's italic is for IAST only.
- Add **4 dp vertical padding** to every Devanagari text box — matras and `ॉ` clip in Android's tight line boxes below 1.4.
- Verse is **centre-aligned in the feed**, **start-aligned in the sheet and lesson reader** (a four-line shloka centred inside a scrolling sheet is hard to re-find).
- **Floors:** shloka never below **20 sp**; Hindi UI never below **13 sp**; Hindi helper text never below **12 sp**.
- Break verses only at **pada boundaries** (`।` / `॥`). Ship `sanskrit` as a pre-split array of padas — never let the layout engine choose, and never hyphenate.
- Device test strings: `कर्मण्येवाधिकारस्ते`, `सङ्गोऽस्त्वकर्मणि`, `श्रेष्ठस्तत्तदेवेतरो`, `द्ध`, `ट्ट`, `क्ष`, `श्र`, `ॉ`.

### 3.4 Language modes and how they change layout

| Mode | Effect |
|---|---|
| **English** | Instrument Sans throughout, Devanagari only for the verse. Meaning 17/28. |
| **हिन्दी** | UI in Noto Sans Devanagari 15/22; reading in Tiro Hindi 17/30. Strings ~10% shorter horizontally but ~15% taller — every button gets `minHeight: 52` and 2-line tolerance. |
| **Hinglish** | UI stays Instrument Sans; meaning is Latin-script Hindi ("Tumhara adhikar sirf karm par hai"). Strings run **~30% longer than English**. No fixed-width chips, no `maxLines: 1` on labels. |
| **Both (Hindi + English)** | Hindi 17/30 then English 14/21 in `inkMuted`. Sanskrit drops 28 → 24 sp; meaning clamps to 3 lines + "Aur padhein". |
| **Transliteration off** | IAST line is removed entirely; the card re-centres and Sanskrit steps up 2 sp. Never leave a gap. |

---

## 4. Shape, stroke, shadow, texture, iconography

### 4.1 Stroke and radius

| Token | Value | Use |
|---|---|---|
| `stroke.hair` | 1 dp | dividers inside a ledger (`borderQuiet` only) |
| `stroke.thin` | 2 dp | chips, inputs, answer rows, path line |
| `stroke.thick` | **3 dp** | cards, buttons, sheets, MP badge, mic — the default |
| `stroke.heavy` | 4 dp | modals, reward plate, crisis card, share frame |
| `radius.xs` | 2 dp | stamps |
| `radius.sm` | **7 dp** | buttons, cards, inputs — HTML `.bt`, `.wc`, `.plate` |
| `radius.md` | **9 dp** | chips, MP badges — HTML `.ch`, `.mp` |
| `radius.lg` | **14 dp** | bottom sheets (top corners only) — HTML `.sheet` |
| `radius.pill` | 999 dp | MP badge, mood chips, avatars, mic |

7 dp is the compromise the prototype already found: enough bevel to read as a stamped card, still hard-edged. v1.0's 4 dp was invented and made the components read as generic rounded rectangles.

### 4.2 Shadow physics

Light from top-left, always. Offset down-right, **zero blur, zero spread**.

| Elevation | Offset | Colour | Applies to |
|---|---|---|---|
| `e0` | 0 | — | full-bleed feed cards, list rows, sheet interiors, anything scrollable that isn't tappable |
| `e1` | **4,4** | border | stamps, chips, small inset blocks — HTML `4px 4px 0` |
| `e2` | **7,7** | border / `#000` on dark | buttons, plate cards, the mic, Sankalp card — HTML `--sh: 7px 7px 0` |
| `e3` | 7,7 | border / `#000` | reward plate, modal, share preview |
| `press` | **3,3** | border | any `e1`/`e2` element while held, which also translates **+4,+4** — HTML `:active` |
| `sheet` | 0,−6 | `#000` | bottom sheet top edge |

Never two shadows. Never a blur. On dark-on-dark, add a 1 dp `rgba(255,255,255,0.06)` top highlight so the object separates from the field.

### 4.3 Texture

- **Paper grain:** 120×120 dp tile, 4% multiply, baked as a ~2 KB PNG. Above `surfaceAged`, below text. Off in Ratri.
- **Deckle edge:** 6 dp inner vignette from `rgba(215,190,142,0.35)`; feed cards and share cards only.
- **Fibre streaks:** two 1 dp diagonal hairlines at 3%, top-left corner only, on splash and reward plate.
- **No texture** on sheet interiors, ledger rows, Yatra background, form fields, crisis screen.

### 4.4 Iconography

Custom 24×24 line set, **2 dp stroke**, square caps, 20 dp in dense rows.

- Nav: `IcScroll`, `IcPath`, `IcMirror`, `IcSangha`, `IcDiya`.
- Objects: `IcLotus`, `IcConch`, `IcChakra`, `IcFlame`, `IcBell`, `IcMic`, `IcBookmark`, `IcShare`, `IcSpeaker`, `IcLock`.
- Motifs (lotus, conch, chariot wheel, diya, peacock feather) are **reward and empty-state art**, never nav chrome.
- No photographs of deities in UI chrome. Art lives on cards.

### 4.5 Motion physics

- Standard curve **easeOutCubic** `(0.215, 0.61, 0.355, 1)`.
- Emphasis curve **easeOutBack** `(0.34, 1.56, 0.64, 1)` — rewards only.
- Sheet spring: stiffness 240, damping 26, mass 1 → ~320 ms with 4% overshoot.
- Durations: press 90 ms down / 140 ms up · state change 200 ms · sheet 320 ms · page transition 280 ms · reward 480 ms · ambient loops 2.4–10 s.
- Nothing exceeds 600 ms except ambient loops and the Yatra path draw (1200 ms, once).
- Every animation has a reduced-motion fallback (§9).

### 4.6 Haptics

| Event | Haptic |
|---|---|
| chip select, tab change | `selectionClick` |
| save, sheet snap, share | `lightImpact` |
| checkpoint correct, Sankalp kept, MP ≥ 10 | `mediumImpact` |
| chapter complete, level up, streak milestone | `heavyImpact` |
| wrong answer, lapsed return, crisis | **none** — never buzz someone for being wrong or sad |

Respect the system setting. Never substitute sound for haptics. No sound in week 1.

---

## 5. Component library

Conventions: heights are minimums; every interactive element has a ≥ 48 dp hit area even when drawn smaller; all labels tolerate 2 lines and 200% text scale.

| Component | Purpose | Variants / states | Motion |
|---|---|---|---|
| **PatentButton** | the only button primitive — a stamped brass plate | primary · secondary · ghost · gold · danger; default/pressed/disabled/loading/success | press translate +2,+2, shadow 5→2, 90 ms; release 140 ms; **no ripple ever** |
| **Stamp** | printed label that makes a screen feel issued, not rendered | gold / paper / field; static only, max one rotated −2°, never tappable | none |
| **ChoiceChip** | onboarding intent, topics, check-in | default / selected (primary fill, shadow 2,2) / pressed / disabled; multi-select capped at 5 | 180 ms fill cross-fade |
| **PlateCard** | the generic parchment surface | `paper` · `aged` · `field` · `gold` · `quiet` (inside sheets) · `flush` (feed base) | press if tappable |
| **ShlokaCard** | the atomic unit: one verse, full screen | `feed` (border, no shadow) · `shared` · `lesson` · `reward`; saving/saved/long-verse/reduced-motion | page settle 280 ms, 12 dp art parallax at 0.88× |
| **VerseRail** | four gestures, always same place, out of the reading path | default / active / awarded / disabled while a sheet is open | MP item pulses 1→1.12→1, 320 ms |
| **SheetHandle** | says "this is a sheet, not a page" | rest / dragging (44→52 dp) / snapping | spring |
| **CheckpointCard** | turns swiping into recall every 7 cards | unanswered / selected / correct / incorrect (gold reveal, **no red, no shake**) / completed | 120 ms fill, 220 ms tick draw |
| **MPBadge** | the wallet, and the only number worth chasing | default / awarding / capped / offline | 1→1.08→1 + 6-particle glint 400 ms |
| **ProgressBar** | Nitya Path, lesson, level | determinate / near-complete (gold) / complete (lotus end cap) | 320 ms width, 480 ms completion sweep |
| **PathNode** | one Yatra lesson on the winding path | done / current (pulsing ring) / locked (still tappable, explains itself) / bonus | ring pulse after 1400 ms |
| **LedgerRow** | one line of the MP truth | positive / zero / negative (`clay`, always with a written reason) / pending | none |
| **MicButton** | the signature act | idle (breathing) / priming / recording / processing / disabled / pressed | 10 s breathing loop; 32-bar waveform while recording |
| **SankalpCard** | the day's one promise, made physical | offered / active / kept / partly / not today / expired — **never red, never "failed"** | 480 ms gold sweep on kept |
| **Toast** | acknowledge without interrupting | entering / visible 2.5 s / exiting / dismissed; never stacks | 180 ms slide+fade in, 140 ms out |
| **EmptyState** | an empty screen should look like held breath | motif at 30% → one line → one ghost action | none |
| **CrisisCard** | the one screen where the product stops being a product | single static state; no border, no shadow, no gold, no brand mark, no gamification | none |

---

## 6. Information architecture and navigation

### 6.1 Sitemap

```
App shell (5 tabs)
├── Shloka          For You · Kram · Topics · expand sheet (3 tabs) · checkpoint · share · library + search
├── Yatra           18-chapter path · lesson player · quiz · chapter summary
├── Mann Darpan     record / type → result → Jeevan Path → Sankalp · journal · crisis support
├── Sangha          weekly league · Parivar · Sakha · invite          (v0.2 — honest preview in week 1)
└── Profile         MP wallet + ledger · level + badges · saved shlokas · journal · settings · privacy
```

### 6.2 The shell

Five tabs, centre tab is the raised mic at 56 dp, translated up 14 dp, `field` fill, 3 dp border, 4 dp shadow. Nav bar 64 dp + safe area.

The mic is **a real branch, not a push**: the wireframe shows the nav bar under the Mann screen, a push would leave a dead tab index, and `indexedStack` preserves a half-typed Mann entry if the user detours into the feed.

### 6.3 Route tree

```
/shloka                        FeedScreen                     (initial after onboarding)
  /shloka/:verseId             VerseFocusScreen                ← share-card deep link target
/yatra                         YatraScreen
  /yatra/chapter/:chapterId    ChapterScreen
  /yatra/lesson/:lessonId      LessonPlayer
  /yatra/lesson/:lessonId/summary
/mann                          MannHomeScreen                  (index 2 — the raised mic)
  /mann/compose · /mann/result · /mann/crisis · /mann/journal
/sangha                        SanghaScreen
/profile                       ProfileScreen
  /profile/saved · /profile/settings · /profile/wallet
/library                       LibraryScreen (pushed over the shell, from the feed's top bar)
/onboarding                    redirect-only shell
  /onboarding/language · /intent · /goal
/signup                        Deferred OTP (root navigator, modal)
/share-card/:verseId           Share card composer (root navigator, full screen)
```

### 6.4 Sheet or route? One rule

**A sheet gets a route only if it must be deep-linkable or must survive process death.**

| Becomes a route | Stays an imperative sheet |
|---|---|
| `/share-card/:verseId`, `/signup`, `/mann/crisis`, `/profile/wallet` | expand sheet, daily reward sheet, level-up, badge sheet, rules sheet, delete confirmation |

The expand sheet uses `showModalBottomSheet(isScrollControlled: true)`. Rationale: back gesture and barrier are free, it is a transient view that needs no restore, and a deep link to "this verse expanded" is unnecessary because `VerseFocusScreen` already shows it.

### 6.5 Deep links

Share URL: `https://dharmascroll.app/shloka/2.47?src=share` (one path segment; go_router matches dots in `:verseId` fine). Android `intent-filter` with `autoVerify="true"` plus `flutter_deeplinking_enabled`.

A deep link lands on **one card**, not the feed. Mutating the ambient feed's position to honour a link would corrupt Kram mode's "resume where I left off" contract; a single card can carry "Continue in the feed →", the expand sheet, and a sign-up chip.

---

## 7. Onboarding

> **Target: first shloka in under 30 seconds.** p50 **20 s**, p90 **27 s**, hard ceiling 30 s. Anything slower is a bug, not a feature.

### 7.1 Timing budget

| # | Step | p50 | Cumulative |
|---|---|---|---|
| 0 | cold start → first frame | 1.2 s | 1.2 |
| 1 | splash (auto-advance 900 ms, CTA live at 500 ms) | 1.4 s | 2.6 |
| 2 | language | 5.0 s | 7.6 |
| 3 | intent + familiarity (one screen) | 6.0 s | 13.6 |
| 4 | Nitya Path (goal + reminder) | 5.5 s | 19.1 |
| 5 | transition + first card paint | 0.9 s | **20.0** |

Instrument `onboarding_step_completed {step, ms}`; alert if p90 > 28 s.

### 7.2 Flow at a glance

```
Splash → Language → Intent + familiarity → Nitya Path → FIRST SHLOKA → coach marks → guest feed
                                                                          │
                                              after 5 cards or first save ─┴→ deferred OTP
```

**Language is the only mandatory step.** Intent has Skip; Nitya has "Set later"; auth has "Maybe later" (twice, then it stops); coach marks dismiss on any gesture; every sheet closes on scrim tap and back.

### 7.3 Screen by screen

#### S1 · Splash — "Dwār"

`surfaceAged` parchment, grain, no nav. ॐ at 64 sp in `accentKesar` (Tiro Sanskrit) at 34% height. Wordmark "DharmaScroll" `d2` Archivo 900. Tagline `b3` `inkMuted`. At 62% height one shloka line: **योगः कर्मसु कौशलम्** in `sktM` `field`, with `m1` below: "YOGA IS SKILL IN ACTION · 2.50". Bottom: block primary **"Shuru karein · Begin"**, `c1` beneath: "No sign-up needed".

Behaviour: auto-advance at 900 ms; CTA live at 500 ms so fast users skip the wait.
Stored: `first_open_at`, `app_version`, `guest_id`.

| | हिन्दी | English | Hinglish |
|---|---|---|---|
| CTA | शुरू करें | Begin | Shuru karein |
| Sub | बिना साइन-अप | No sign-up needed | Bina sign-up |
| Tagline | स्क्रॉल कम। जीवन ज़्यादा। | Scroll less. Live more. | Scroll kam. Jeevan zyada. |

#### S2 · Language & script — "Bhasha"

**"Step 1 of 3" with a 33% bar.** The source puts the counter on this screen and it is a commitment device, not a progress indicator — removing the first third (as v1.0 did) made the flow feel shorter than it is. The title is a **three-line stack** (Devanagari / Hinglish / English); tapping a row **animates the title into that language in 200 ms**. That is the screen's whole delight, and it doubles as a live preview.

Four 64 dp rows, 2 dp border, radio at right:

| Row | Label |
|---|---|
| 1 | हिन्दी + संस्कृत *(default)* |
| 2 | English + Sanskrit |
| 3 | Hinglish (dono) |
| 4 | मराठी · বাংলা · தமிழ் … → *(opens an honest "coming soon" sheet; does not block)* |

Then a 1 dp rule and one toggle row: **"Pronunciation dikhao / दिखाएँ / Show transliteration"**, ON by default. Helper `c1`: "Baad mein Settings se badal sakte hain."

Primary **"Aage · Next"**. No secondary, no skip — language is not skippable, but it is one tap. Written on selection so a kill mid-screen resumes correctly.

#### S3 · Intent + familiarity — "Kyun aaye"

Progress 1 of 3. Multi-select chips, **cap 5**: Less phone time · Stress & anxiety · Finish the Gita · Anger · Focus for exams · Career confusion · Relationships · Grief · Daily devotion · Teach my kids. A sixth tap shows a gentle toast: *"5 hi chunein, warna feed dhundhla ho jayega."*

Inline second block, no new screen: **"How well do you know the Gita?"** → New · Read a few · Studied it, mapped to `difficulty_pref` 1/2/3. New starts the For You blend at Ch 2 and 12; Studied starts at Ch 1 with fewer repeats.

Primary **"Aage · Next"**. Secondary ghost **"Skip"** → stores `intents: []` and `familiarity: null`, defaulting to New. An empty array is a deliberate skip, not "unset".

#### S4 · Nitya Path — "Roz ka waqt"

Progress 2 of 3. Three 60 dp rows: **5 min · Casual** ("1 shloka") / **10 min · Regular** ("5 shlokas + 1 checkpoint", default, kesar left edge) / **20 min · Serious** ("5 shlokas + Yatra lesson").

Then **"Remind me at"**: chips **6:30 am** (default) / **9:00 pm** / **+ Custom** (24 h picker).

Two lines of microcopy carry this screen:

> **"Includes 2 free Vishram days a month. Rest is part of the practice."**
> **"We'll ask before we ever send a reminder."**

That second line is literally true — the OS prompt has not been shown yet, and will not be shown here.

Primary **"Start my first shloka"**. Secondary ghost **"Set later"** → proceeds to the feed; a reminder card appears at position 3 instead.

#### S5 · First shloka — the value moment

Card 0 is always **2.47** — the brand verse, four padas, the same one on the splash and the marketing site. It arrives **already full-screen and interactive**: swipe works, tap works, save works, rail works. A 44 dp strip above the rail reads `m1` "AAJ KA PEHLA SHLOK", holds 3 s, fades.

The first card carries a **"+2 MP" pulse on the rail before any account exists**. The number is real, it stays in the local ledger, and it is the currency the later OTP ask is denominated in.

**Coach marks** are an overlay state on the same screen, not a screen: a `field`-filled plate docked to the bottom (max 240 dp) with `m1` "How DharmaScroll works" and four lines — **↑ Swipe up for the next shloka · ◎ Tap to go deeper · ♡ Double-tap to save · ● Hold the mic to share your day**. Dismissed by the first swipe, the first tap, or "Samajh gaya". Never blocks a gesture, and **never auto-hides on a timer** — a reader who spends 40 seconds on the verse should still have the hints. Shown once per install.

**Onboarding ends** when the first card is painted, textured, and the coach is dismissed or auto-hidden at 8 s. `FEED_GUEST` is the terminal state.

### 7.4 Value before ask — the exact moments

| Ask | When | Why here |
|---|---|---|
| **Language** | step 2, before any content | cheap, one tap, makes the first card legible. A preference, not a permission. |
| **Notification permission** | OS prompt fired from the **reminder card at feed position 3**, only if a reminder time was set | the user has read 3 shlokas; the ask now has a referent |
| **Phone OTP** | after the **5th unique card, or the first save**, whichever lands first | there is something to lose. Copy prices the ask in points, not in "create an account". |
| **Google sign-in** | same sheet, secondary | never the only path; phone is primary in India |
| **Mic permission** | first mic tap, after a one-sentence in-app rationale | contextual, and the user initiated it |
| **Nothing else** | — | no contacts, no location, no tracking prompt, no review prompt before day 7 |

### 7.5 Deferred OTP — exact behaviour

Sheet: `radius.lg`, 3 dp border, handle, `surface`. Header: MP badge **"◉ 10 MP"** centred. Title `t2` **"Save your Moksh Points"**. Sub `b3` *"and your saved shlokas, on any phone"* / *"और आपके सहेजे श्लोक — किसी भी फ़ोन पर"* / *"aur aapke saved shlok, kisi bhi phone par"*.

Field: `+91` prefix plate + 10-digit input (`m2`, tabular). Primary **"Send OTP"**. Secondary **"Continue with Google"**. Ghost **"Maybe later"**.

- Dismissed once → don't re-ask for 3 sessions or until the next save.
- Dismissed twice → don't ask again this week; the wallet shows a one-line nudge ("Guest mode. Points are on this phone only.").
- On success: local ledger migrates by `idempotency_key`, a 700 ms "Merging your 14 MP…" state, then toast "Sab sambhal liya. 14 MP safe hain."
- OTP failure: inline `b3` under the field — no red banner, no shake: "Code nahi aaya? 30s mein phir bhejein" with a live countdown.

### 7.6 State machine

| State | Entered by | UI | Exits |
|---|---|---|---|
| `OB_BOOT` | cold start | native splash, parchment colour | fonts ready → `OB_RESUME_CHECK` |
| `OB_RESUME_CHECK` | boot | invisible | no `lang` → `OB_SPLASH`; `lang` set, `nitya` null → `FEED_GUEST`; complete → `FEED_SESSION`; deep-link payload → `DEEP_LINK` |
| `OB_SPLASH` | resume check | S1 | auto 900 ms / CTA → `OB_LANG` |
| `OB_LANG` | splash | S2 | selection + Next → `OB_INTENT` |
| `OB_INTENT` | language | S3 | Next / Skip → `OB_NITYA` |
| `OB_NITYA` | intent | S4 | Primary / Set later → `FEED_FIRST` |
| `FEED_FIRST` | Nitya | card 0 + coach overlay | first swipe/tap → `FEED_GUEST` |
| `FEED_GUEST` | card engaged | feed, guest wallet | save or 5th card → `AUTH_PROMPT` |
| `AUTH_PROMPT` | trigger | sheet over feed | Send OTP → `AUTH_PHONE`; Google → `AUTH_VERIFY`; later → `FEED_GUEST` |
| `AUTH_PHONE` → `AUTH_OTP` → `AUTH_VERIFY` | — | number → 4-box code → merge overlay | success → `FEED_MEMBER` |
| `FEED_MEMBER` | verified | synced feed | — |
| `DEEP_LINK` | URL /shloka/{id} | shared-verse card | "Apna pehla shlok →" → `OB_LANG` if no `lang`, else `FEED_FIRST` at that verse |
| `LAPSED_3` | open after 3–9 days | feed + one welcome-back line | any action → `FEED_SESSION` |
| `LAPSED_10` | open after ≥10 days | "Teen darwaze" sheet | choice → `FEED_SESSION` |

**Interruption is normal, not an error.** Killed at S3 → resume at `OB_NITYA` only if the user has never seen a card; otherwise resume **into the feed** and deliver Nitya as card 2. Never re-ask a question already stored.

### 7.7 Persistence

**Decision: `shared_preferences` owns settings and onboarding flags. Drift owns everything that grows.**

The plan assumed Drift for everything, which puts a SQLite open on the 30-second critical path. Prefs read in 2–5 ms, before the first frame.

| Store | Fields |
|---|---|
| prefs | `onboardingComplete`, `lang`, `showIast`, `intents`, `gitaFamiliarity`, `dailyGoalMin`, `dailyGoalVerses`, `remindAtMinutes`, `reminderEnabled`, `onboardingStep` + `stepIndex`, `firstVerseId`, `cardsSeen`, `authPromptCount`, `coachSeen`, `nityaDeferred`, `themeMode`, `textScale`, `timezone`, `deviceLocale` |
| Drift | `mp_ledger`, `user_stats`, `verse_state`, `sankalps`, `mann_entries`, `view_events`, `quiz_attempts` |

Two stores, **one owner each**. SharedPreferences is the single owner of settings and never gets a Drift mirror — the failure to avoid is language stored in both and disagreeing.

### 7.8 Returning, lapsed, deep-linked

**Returning (≤ 48 h).** 400 ms splash, no ceremony, feed at last index with a 200 ms fade. Mid-Kram: toast "Kram 3.21 se aage". No "welcome back" modal.

**Lapsed, day 3.** No modal, no lost-streak screen, no red. One line where the Nitya dots sit, `c1`: **"Wapas aa gaye. Aaj bas ek."** Yesterday's Sankalp is silently marked *expired*, not *failed* (`−10` suppressed after a 48 h gap — absence forgiveness). Flame shows at 60% with no number. The first card is the lowest-effort one available.

**Lapsed, day 10.** One sheet, no illustration, no guilt:

> `t2` **"10 din. Koi hisaab nahi."** / "10 days. No accounting."
> `b3` "Tumhari 43 din ki yatra kahin nahi gayi. Aaj ek shlok se phir shuru karein."

Three 60 dp doors, each with a `m1` time estimate: **5 shlokas · 3 min** · **Ek Mann Darpan · 2 min** · **Ek Yatra lesson · 4 min**. Ghost: **"Bas khol ke dekh raha hoon"** — opens the feed, awards nothing, asks nothing. Streak resets to 1 visibly, but `total_days` and all points survive and are shown as "43 din ki yatra" in Profile.

**Deep link.**

| Situation | Behaviour |
|---|---|
| installed, warm | shared-verse card with "A FRIEND SENT THIS" stamp + "Apna pehla shlok →". Back returns to the feed. |
| installed, cold | splash cut to 300 ms → shared verse. No language screen if `lang` exists. |
| fresh install | language only (4 s, one tap) → shared verse. Intent and Nitya arrive as feed cards at positions 2 and 3. **Target 6 s, not 20.** |
| bad id | falls back to 2.47 with a toast — never a dead 404 |
| `ref=<user>` | stores `referrer`; awards +50 only when the invitee completes a Nitya Path, never on install |

**Failure states.** Fonts not ready → system fallback, hold the first card max 250 ms, then render anyway. Offline at first launch → everything still works, the feed is bundled. Seed data missing → one PlateCard "Content load nahi hua. App band karke dobara kholein." with Retry. Never a blank screen.

---

## 8. Screen specifications

### 8.1 Shloka feed

**Purpose:** the daily ritual; the replacement for reels muscle memory.

**Top bar (52 dp):** segmented text control `FOR YOU · KRAM · TOPICS` (active = ink + 3 dp kesar underline), then streak flame + count, Nitya dots (5 × 8 dp), MP badge.

**Anatomy of the card** (top to bottom, exactly the order the wireframe and PDF page 17 use):

1. **Header** — `ADHYAY n · {YOGA} · SHLOKA n` in mono at 10–11 sp, plus the MP pill. Caps at 52 dp.
2. **Art layer** — the aged gradient, grain, and one procedural motif at 7–9%, behind everything.
3. **Sanskrit** — the largest element on the screen, centred, pre-split at pada boundaries. 28 sp (`sktL`), 24 sp (`sktM`) below 380 dp.
4. **IAST** — italic, muted, one or two lines. Hidden entirely when transliteration is off.
5. **Hindi meaning** — Tiro Hindi 17/30, centred.
6. **English meaning** — Instrument Sans 14/21, muted, centred.
7. **"Tap to go deeper"** — the affordance that makes the sheet discoverable. A 2 dp outlined chip, not a sentence.
8. **Right rail** — Save · Share · Deepen · `+2 MP`, 44 dp wide, bottom-anchored, never overlapping the last line.
9. **Gestures** — tap to expand, double-tap to save, long-press to share, swipe up for the next card.

The v1.0 document had no anatomy at all, which is why three source elements (the Hindi line, the deepen chip, long-press) went missing.

**Modes.** *For You* = deterministic blend, 40% next-in-Kram / 30% intent-matched / 30% famous, and every card carries a 9 sp `m1` reason under the ref ("FOR YOU · ANGER", "KRAM · 2.47") so the feed never feels random. *Kram* = sequential, resumes, remembers index. *Topics* = 8 chips (anger, fear, duty, love, focus, grief, success, devotion).

**States.** loading (skeleton card, 200 ms max) · empty topic ("Is topic mein abhi 4 shlok hain. Baaki week 3 mein.") · end-of-Kram · **speed-scroll pause** (a `field` card: "Thoda ruko. Shlok padhne ke liye hai, ginne ke liye nahi." then 10 minutes with no points, no penalty) · offline (3 dp dotted top bar, points queue silently).

**Delight.** The page settle — 280 ms with 12 dp art parallax and a 1 px paper-peel shadow at the bottom edge, so a swipe feels like turning a leaf.

### 8.2 Expand sheet (Shabdarth / Katha / Jeevan)

Handle; three stamps as tabs, active filled `field`; detents 0.62 and 0.92; scrim 55%.

- **Shabdarth** — word rows: Devanagari `sktS` (20 sp floor), IAST, gloss, 1 dp `borderQuiet` between; then an "Anvaya" block in `surfaceSunken`.
- **Katha** — speaker→listener chip pair, scene paragraph `b1`, and a 2 dp `field` left rule quoting the chapter's situation.
- **Jeevan** — 60–90 word lesson `b1`, then a `gold` strip: **"✦ Make this my Sankalp"**.

**Delight.** The tab switch does not animate the sheet — only the content cross-fades 160 ms, so the paper stays still and the words change, like a page turning under glass.

### 8.3 Checkpoint

Every 7th unique card, **max 3/day**, never a full-screen interrupt, always swipable, never timed. `+5` on correct. **A wrong answer costs nothing** — the blueprint's `−5` for guessing punishes curiosity, which is the product's whole value. Note the deviation in the changelog.

### 8.4 Nitya Path completion + reward

The current card dims to 30% behind a `surface` sheet — never a full-screen takeover. Sheet: `IcLotus` 48 dp in gold → `d2` **"Nitya Path complete"** → `b3` "13 days in a row" → week strip of 7 squares (done = gold with day letter, Vishram = `field` with "V", missed = hollow) → itemised ledger block → level bar "Shravak → Sadhak · 260 MP to go" → primary "Share my streak" → ghost `c1` **"Keep scrolling — no more points today, just peace."**

**Delight.** The week strip fills left-to-right with a 60 ms stagger and the last square lands with one `mediumImpact`. No confetti, no sound, no takeover. Restraint is the reward — and this is the screen that proves the product isn't another slot machine.

### 8.5 Share card composer

Ratri chrome; 9:16 preview 260×462, 4 dp border, 7 dp shadow; theme stamps **PARCHMENT · MADHUBANI · RATRI**; four targets (Instagram Story, WhatsApp, Status, More); watermark `m1` "GITA 2.47 · DHARMASCROLL" + ॐ at 8%; deep link in the caption.

Export 1080×1920 PNG via `RepaintBoundary`; verse at 2.8× scale; safe-area guides (top 250 px, bottom 340 px) as 1 dp dashed lines only while composing. Theme switch = 240 ms paper-swap (old sheet slides down 8 dp and fades under the new one). Failure copy: "Share nahi hua. Image save kar lein?" — never a silent failure.

### 8.6 Library

Search field (`surfaceRaised`, 2 dp border, placeholder "Search 'anger', '2.47', 'Arjuna'") · scripture chips (Bhagavad Gita active; Ramayana / Upanishads disabled with "soon") · 18 chapter rows at 64 dp with numeral `d3` `field`, name `h1`, and real verse counts (47, 72, 43, 42, 29, 47, 30, 28, 34, 42, 55, 20, 35, 27, 20, 24, 28, 78).

Locked chapter rows are 60% opacity with a lock, and still open a three-verse preview — never a dead tap. **Delight:** on focus the search border thickens 2→3 dp and gains an `e1` shadow; the page leans toward you.

### 8.7 Gita Yatra

Path on `surfaceAged`; chapter header as a `field` PlateCard (adhyay number, yoga name, "Lesson 3 of 7 · Action without attachment"); then a `CustomPaint` winding path (dashed 3 dp, dash 1/6) with nodes alternating in a three-node wave, chapter badges every 7 nodes, and 15 locked chapters with honest labels ("opens in week 3").

Lesson player: full screen, close + `m2` "3 / 5" + progress bar, five shlokas at `sktM` start-aligned, then a 3-question quiz using the same answer-row component, then a chapter summary plate with a Sankalp extraction.

**Delight.** The path draws itself once, 1200 ms, from node 1 to the current node. One 1.2-second ritual per chapter, then never again.

### 8.8 Moksh Points wallet

`field` header (gold `m1` "LEVEL 2 · SHRAVAK", `d2` "1,240" in gold, progress to "260 MP to Sadhak") → three stat plates (+312 this week / 2 Vishram left / 13-day streak) → "Today" → 4–8 LedgerRows → "Poori history" → "Rules".

**States:** capped ("aaj ki seema poori — kal 12 baje ke baad") · guest ("Sirf is phone par. Save karein?") · offline (rows at 70%) · empty day one ("Pehla +2 aapke pehle shlok se aaya.").

**Delight.** The level bar's fill carries a tiny lotus at its leading edge that bobs 2 dp as it advances — the only cute thing in the economy.

### 8.9 Daily Sankalp

**Create** from any Jeevan tab or Mann Darpan's Jeevan Path. `gold` card prefilled with the verse's action line, editable inline (80 char max, live counter), reminder chips, primary **"Sankalp lein"** → 220 ms gold wash + `mediumImpact` + toast "Sankalp liya. Shaam ko poochhenge."

**Check-in** (21:00 local, in-app sheet if open, otherwise a notification that opens it): the promise quoted with a 2 dp `gold` left rule, then **three equal-width, equal-weight buttons** — "Hua ✓" · "Aadha hua" · **"Aaj nahi hua"**. Then `c1`: **"Sach bolne ke points hain. Jhooth ke nahi."** Done +25, partly +10, not-today **0** plus "Theek hai. Kal ek chhota sa try."

**Delight.** "Hua" fills the card with `successTint` and stamps it — the promise literally becomes a different object.

### 8.10 Mann Darpan

**Idle (Ratri).** "Journal" · "Mann Darpan" · ⓘ. `d3` gold **"Aaj ka din kaisa tha?"**. Five optional mood chips. Mic 96 dp at 58% height with a breathing ring. "Hold to speak · or type instead" — the type-instead is a real 44 dp target. Privacy line. **Week 1 reads "🔒 Private. Sirf is phone par."** because nothing leaves the device yet; do not claim deletion that isn't happening.

**Recording.** `m1` "● LISTENING · 0:38" with a blinking dot; 32-bar waveform; live transcript card (2 dp dashed gold border, "tap to edit"); stop 64 dp `dangerFill` circle; auto-stop at 2:00.

**Processing (2–4 s).** Lotus with a rotating dashed gold ring, `t2` "Finding your shloka…", a four-line checklist resolving one per ~600 ms (✓ Heard you · ✓ Feeling: hurt, unappreciated, anger · ✓ Situation: work feedback, family · ◌ Searching shlokas…), and italic under it: *"Pause. Breathe in for 4… out for 6."* The breathing cue **is the latency cover** — a three-second wait feels like a pause, not a spinner.

**Result.** The **Prabhat transition**: 520 ms cross-dissolve Ratri → Patra with 12 dp upward drift ("night question, morning answer"). Ref, verse `sktM`, meaning, "Why this shloka" as a `quiet` plate with a 2 dp `field` left rule quoting the user's own words, then **"What do I do? →"** and **"Another shloka"**.

**Jeevan Path.** Three numbered action plates (numeral `d1` at 30%, action bold, explanation `b3`), SankalpCard, "Take this Sankalp", footer "Saved privately to your journal".

**Crisis.** Before retrieval, always. No points, no journal gamification, mic stays available. No gold, no brand mark, no shadow, no motion.

Copy is fixed by the source and must ship verbatim: headline **"You don't have to carry this alone"**, paragraph **"What you shared sounds really heavy. Talking to someone trained can help right now."**, then **Tele-MANAS (free, 24×7) · 14416 or 1-800-891-4416**, the red **Call now**, **Message someone I trust**, **"If you're in immediate danger, call 112."**, and the closing **"Stay here with a calming chant ▶"**. Both numbers, every time — dropping one is not a design choice.

**Journal.** Grouped by month; row = date `m1`, mood glyph, first line of transcript, matched ref, outcome. Month footer: a 2 dp kesar line chart and one computed sentence — "Calmer on days you kept your Sankalp." Never moralising.

**States:** idle · priming · recording · transcribing · no-speech ("Awaaz nahi aayi. Dobara try karein ya type karein.") · offline (type-instead still works against the local tag index) · rate-limited (3 free/week: "Is hafte ke 3 ho gaye. Somvaar se phir.") · empty journal.

### 8.11 Sangha (week 1)

An **honest preview, zero fabricated users**. Three disabled tabs (Tulsi League · Parivar · Sakha) with an `m1` "V0.2" stamp; one card: *"League abhi band hai. Hum sacche logon ke saath hi kholenge — nakli leaderboard nahi banayenge."* / *"Leagues open in v0.2. We won't invent players to fill a table."* Your own week strip and streak; primary "Invite a Sakha" (share sheet with a personal note); secondary "Notify me".

**Delight.** The empty league table is 30 one-dp rows fading out at the bottom — a room being prepared, not a broken page.

### 8.12 Profile / Settings

Avatar 56 dp (gold 3 dp ring), name, "Shravak · joined Nov 2026"; three stat plates; badges 4-up (only real ones; locked ones are silhouettes with honest counts); rows for Saved shlokas, Journal, Mood over time, Settings.

Settings: Language · Transliteration · **Text size 100–200% with a live preview of the actual first shloka line** (not Lorem Ipsum) · Auto Ratri · Daily goal · Reminder · Haptics · Privacy ("Delete everything" in `danger`, confirm sheet requiring the typed word `DELETE` — the only place we make the user type) · About · Rules · *"No ads. No data sold. Ever."*

---

## 9. Interaction and motion specification

| Name | Trigger | Spec | Reduced motion |
|---|---|---|---|
| **Lotus save burst** | double-tap / rail save | 6 petals 0.4→1.15→1, 24° rotation, 60 ms stagger, gold, 480 ms easeOutBack; ripple at touch point 320 ms | static gold lotus fades in 120 ms, holds 240 ms |
| **Coin glint** | any MP award | badge 1→1.08→1 (320 ms) + 6 particles rise 24 dp and fade 400 ms; ghost "+2" drifts up 12 dp, fades 600 ms | instant number, 120 ms outline flash |
| **Card parallax** | page settle / drag | header and meaning 1.0×, art 0.88×, max 12 dp, 280 ms easeOutCubic | no parallax, 120 ms cross-fade |
| **Sheet spring** | open / detent | 320 ms spring (240/26/1), scrim 55% fades 200 ms; dismiss at 30% height or > 800 dp/s | 160 ms slide, no overshoot |
| **Path draw** | first entry per chapter | dash reveal 1200 ms, nodes pop in 60 ms stagger, pulse after 1400 ms | drawn instantly, ring static |
| **Streak flame** | idle | 2.4 s loop, scale 1→1.04, opacity flicker 0.92–1.0; stops off-screen | static |
| **Breathing cue** | processing, idle mic | 10 s: inhale 4 (0.86→1.0), hold 2, exhale 6 | static ring 0.94 + text |
| **Prabhat transition** | Mann result | 520 ms cross-dissolve Ratri→Patra, 12 dp drift, 1 px gold hairline sweep | 200 ms fade |
| **Press physics** | any liftable control | down 90 ms (+2,+2, shadow 5→2), up 140 ms easeOutCubic | opacity 100→88% |
| **Correct answer** | checkpoint / quiz | fill 120 ms, ✓ stroke 220 ms, one `mediumImpact` | instant |
| **Track fill** | progress bars | width 320 ms; completion sweep 480 ms gold | instant |
| **Toast** | system events | 16 dp slide + fade 180 ms in, 140 ms out, 2.5 s dwell | fade only |
| **Page transition** | nav push/pop | 280 ms shared-axis, 24 dp slide + fade; tab switches fade only | 120 ms fade |

**Global rules.** No looping animation on more than one element at a time. No animation blocks input — everything is interruptible. No sound in week 1. All motion respects the OS reduce-motion flag **and** a manual "Motion: Reduced" setting.

---

## 10. Accessibility and localisation

**Text scaling.** Everything honours `textScaler` to **200%**. Above 130% the feed card changes layout: IAST hides, the rail goes icons-only, and the verse scrolls inside the card rather than clipping. Buttons grow. Nothing carries `maxLines: 1` except the mono stamp. Test at 100 / 130 / 160 / 200%.

**Tap targets.** 48×48 dp minimum everywhere, including 9 sp rail labels (zone 48×56). Nav tabs 64×64. Chips are visually 36 dp inside a 48 dp hit box. Mic 96 dp. Sheet handle 44 dp tall.

**Screen-reader labels** (paste verbatim):

- Mic — *"Mann Darpan. Hold to speak about your day. Recording starts when you hold and stops when you release. Double-tap to type instead."* While recording — *"Recording. 38 seconds. Release to stop."*
- Shloka card — *"Bhagavad Gita, chapter 2, verse 47. Sanskrit verse. Meaning: You have a right to your work, never to its results. Double-tap to open word-by-word meaning."* The verse is announced as one item, never glyph by glyph.
- Rail — *"Save this shloka"* / *"Share this shloka"* / *"Open word-by-word meaning, story and life lesson"* / *"2 Moksh Points earned."*
- MP badge — *"1,240 Moksh Points. Level 2, Shravak. 260 points to Sadhak."*
- Path node — *"Chapter 3, Karma Yoga, lesson 3 of 7. Current lesson."* Locked — *"Chapter 4, locked. Opens in week 2."*
- Progress — `Semantics(value: "3 of 5")`, never a bare bar.
- Crisis — reading order headline → numbers → call; numbers are separately tappable, *"Call Tele-MANAS, 1 4 4 1 6"*.

**RTL.** Not required. Hindi, Hinglish and English are all LTR; so are Marathi/Bengali/Tamil. Urdu would need RTL work — out of scope, and said plainly in release notes rather than pretended.

**Localisation mechanics.** Hinglish runs ~30% longer than English: no fixed-width buttons, chips wrap at 8 dp, nav labels drop to 9 sp before ever truncating. Hindi is ~15% taller: every row gets `minHeight` and 4 dp slack. The mono font has no Devanagari — an `m1` stamp that must render Hindi falls back to Noto Sans Devanagari at 11 sp with reduced 0.06 em tracking. Numbers stay Latin and tabular in all languages (`1,240`, `2.47`); Indian grouping (`1,24,000`) above 99,999.

---

## 11. Anti-dark-pattern rules

These are product requirements, not copy guidelines. A build that violates one is not shippable.

1. **There is a "done for today."** When Nitya Path is met, the sheet says so plainly: *"Keep scrolling — no more points today, just peace."* The feed still works; the game stops.
2. **No infinite badges.** Finite, named, once. Locked items are silhouettes with honest counts, not a bottomless ladder.
3. **No red dots.** No tab badges, no unread counts. The only dot in the product is the 8 dp "will sync" dot on the MP badge.
4. **Streaks are protected, not weaponised.** Two Vishram days a month, plus one per 7-day streak (max 5 banked). *"Your 12-day streak is about to end!"* is a notification this product may not send. A break shows the flame at 60% with no number.
5. **Mood is never scored negatively.** No deduction for sadness, no lower points for a low entry, no streak penalty for a hard day. A crisis entry is excluded from all game logic and never acknowledged in the ledger.
6. **The honest answer is the same size as the happy one.** "Aaj nahi hua" is a full-width button at the same weight as "Hua".
7. **No punitive red.** Ledger negatives use `clay`, once per screen, with a written reason. `danger` is reserved for crisis and destructive actions.
8. **No slot machine.** No pull-to-refresh reroll, no randomised rewards, no "spin", no variable-ratio payouts. Awards are fixed, listed, and pre-announced.
9. **Push ≤ 2/day, never 22:00–07:00**, auto-reducing after 5 ignored in a row, then stopping until the app is opened. Every push names a real thing; none threatens.
10. **No fabricated social proof.** No fake users, no invented leaderboard, no "4,210 seekers joined". Sangha ships as an honest empty room.
11. **Leagues score depth only** — lessons, checkpoints, Sankalp, Mann Darpan. Raw swipes cannot win, so the leaderboard cannot reward the behaviour the product exists to cure.
12. **Session length is a guardrail, not a goal.** Median session time is tracked; if it passes 14 minutes that is a bug report, not a win.

---

## 12. Engineering architecture

### 12.1 Layers and the dependency rule

| Layer | Contains | May import |
|---|---|---|
| `core/` | theme, tokens, router, design-system widgets, constants, small utils | `core/` + Flutter + go_router |
| `domain/` | models, MP rules, streak/Vishram engine, crisis gate, retrieval scorer, **repository interfaces**, domain services | `dart:*` only — **no Flutter, no packages, no `core/`** |
| `data/` | asset repository, Drift database + DAOs, prefs, platform services | `domain/`, `core/` |
| `presentation/` | shell, screens, feature widgets, Riverpod notifiers | `domain/`, `core/` — **never `data/`** |
| composition root (`app.dart`, `app_providers.dart`, `main.dart`, `bootstrap.dart`) | `ProviderScope`, theme, router, provider overrides | everything |

**Why `domain/` imports nothing.** The MP rule engine is the one module that must later run identically on a server, in a test, and inside an isolate. If it imports `intl` or `uuid`, it can never leave the app. Enforcing pure Dart as an import rule makes the week-2 server move a copy-paste, not a rewrite.

**Why `presentation/` never imports `data/`.** Widgets talk to interfaces and providers, so every screen is testable with an in-memory fake, and swapping SQLite for Supabase touches `data/` and one provider line — not forty screens.

```
main.dart ─► app.dart ─► ProviderScope(MaterialApp.router)
             app_providers.dart = composition root (the only file naming data/ classes)
                          │
      ┌───────────────────┴────────────────────┐
      ▼                                        ▼
presentation/ (screens + notifiers)      core/ (theme, router, widgets)
      │ imports                                ▲ imports
      ▼                                        │
domain/ (pure Dart: models, mp_rules,          │
         streak, crisis_gate, retriever,       │
         repo interfaces) ─────────────────────┘
      ▲ implements interfaces
      │
data/ (asset repo, drift + daos, prefs, platform services)
```

**Enforcement:** `test/architecture_test.dart` greps `lib/` and fails on forbidden imports. Three tests, cheap, and they survive new contributors.

### 12.2 Folder tree

Layer-first at the top, feature-first inside `presentation/`. The repo already commits to `core/` + `presentation/` and the plan commits to `data/`; going fully feature-first would rename what the team already agreed on for a 7-day build. But inside `presentation/`, one folder per tab is strictly better than one `screens/` pile — five bounded contexts, and by Day 5 `screens/feed/widgets/` would hold 14 files.

```
lib/
  main.dart                            one-liner: ensureInitialized + runApp(ProviderScope)
  app.dart                             MaterialApp.router, themes, textScaler clamp
  app_providers.dart                   COMPOSITION ROOT — the only file importing data/
  bootstrap.dart                       BootstrapResult: prefs + settings, resolved once
  core/
    constants/app_constants.dart       app name, MP rule version, asset paths, feature flags
    theme/app_colors.dart              AppColors ThemeExtension (light + Ratri) + scheme builder
    theme/app_type.dart                const TextStyle metrics (Latin + Devanagari)
    theme/app_metrics.dart             AppSpace, AppRadius, AppBorder, AppShadow, AppMotion
    theme/app_theme.dart               ThemeData assembly
    theme/theme_x.dart                 context.colors / context.type / context.devText
    router/app_router.dart             GoRouter + StatefulShellRoute + redirect
    router/routes.dart                 path/name constants (no string literals elsewhere)
    router/sheet_route.dart            showAppSheet<T>() — the one place sheets open
    widgets/hard_shadow.dart           HardShadow — offset solid plate, no blur
    widgets/plate.dart                 Plate — parchment surface + optional shadow
    widgets/hard_button.dart           HardButton — press-down translate + shadow collapse
    widgets/{stamp,eyebrow,tag_chip,mp_pill}.dart
    widgets/{async_value_view,skeleton}.dart
    utils/{date_time_x,result}.dart
  domain/
    models/{verse,mp_event,mp_context,mp_decision,ledger_entry,mp_snapshot,user_stats,
            sankalp,mann_entry,lesson,streak_result}.dart
    mp/{mp_day,mp_rules,streak_engine,mp_award_service}.dart
    mann/{crisis_gate,text_normalizer,mann_retriever}.dart
    repositories/{verse,mp_ledger,sankalp,journal,progress,settings}_repository.dart
  data/
    assets/{asset_verse_repository,verse_json_parser,verse_index_builder}.dart
    db/{app_database,tables,converters}.dart
    db/daos/{mp_ledger,user_stats,verse_state,sankalp,mann,view_events,quiz}_dao.dart
    repositories/{drift_mp_ledger,drift_sankalp,drift_journal,drift_progress,
                  prefs_settings}_repository.dart
    services/{audio_capturer,record_audio_capturer,notification_service,share_card_service}.dart
  presentation/
    shell/{app_shell,shloka_nav_bar,streak_header}.dart
    onboarding/{onboarding_flow,onboarding_notifier}.dart
    onboarding/steps/{splash,language,intent,goal}_step.dart
    onboarding/widgets/choice_tile.dart
    feed/{feed_screen,feed_controller,feed_item_controller,feed_providers}.dart
    feed/widgets/{shloka_card,card_header,card_rail,expand_sheet,sheet_tab_bar,
                  checkpoint_card,slow_down_card}.dart
    feed/anim/{lotus_burst,coin_glint}.dart
    yatra/{yatra_screen,chapter_screen,lesson_player,quiz_view,yatra_providers}.dart
    mann/{mann_home_screen,mann_compose_screen,mann_result_screen,crisis_screen,
          journal_screen,mann_session_notifier,mann_providers}.dart
    sangha/sangha_screen.dart
    profile/{profile_screen,saved_screen,settings_screen,badges_sheet}.dart
    mp/{mp_wallet_screen,mp_award_notifier,mp_providers,daily_reward_sheet}.dart
    share/{share_card_editor,share_card_canvas}.dart
    common/{coach_marks_overlay,error_screen}.dart
assets/
  verses/gita_seed.json
  fonts/ (6 families + OFL.txt)
  art/            (empty in week 1; folder exists so paths don't churn)
test/
  architecture_test.dart
  domain/{mp/{mp_rules,streak_engine,mp_day}_test.dart, mann/{crisis_gate,mann_retriever}_test.dart,
          verse_parse_test.dart}
  data/mp_ledger_dao_test.dart
  presentation/{feed_screen,expand_sheet,onboarding,mp_pill}_test.dart
  fixtures/mann_inputs.dart
  support/db.dart
```

Changes from the plan's proposed tree, with reasons: `data/models` → `domain/models` (models are the contract between layers; under `data/` the widget layer imports `data/` by proxy); `data/repositories` split into `domain/repositories` (interfaces) + `data/repositories` (implementations); `data/services/local_db.dart` → `data/db/`; `presentation/screens/feed/widgets/` → `presentation/feed/` (drop `screens/` and `widgets/`, both add a level for nothing).

Deleted: `lib/presentation/screens/home_screen.dart`. Rewritten: `test/widget_test.dart` (it currently asserts `HomeScreen` and its icon).

### 12.3 State management

**`flutter_riverpod` 3.x, `Notifier`/`AsyncNotifier`, no codegen.**

- `Notifier` over `StateNotifier`: in Riverpod 3 the legacy providers moved to `riverpod/legacy.dart`; new code against them is building on a deprecation.
- No `riverpod_generator`: a 7-day build needs the provider graph to be *greppable*. Handwritten providers cost ~4 lines each and win the debugging week. Revisit at week 4.

| Provider | Type | Responsibility |
|---|---|---|
| `sharedPrefsProvider` | `Provider` | synchronous boot flags (overridden in `main`) |
| `appDatabaseProvider` | `Provider` | single Drift instance, lazy, closed on dispose |
| `clockProvider` | `Provider<Clock>` | injectable `DateTime Function()` for tests |
| `deviceOffsetProvider` | `Provider<Duration>` | UTC offset for day buckets |
| `verseRepositoryProvider` / `verseCatalogProvider` | `Provider` / `FutureProvider` | asset loading, parsed catalog + tag index + idf |
| `mpLedgerRepositoryProvider` | `Provider` | append/read/watch |
| `settingsProvider` | `NotifierProvider` | language, translucency, theme, text scale |
| `onboardingProvider` | `NotifierProvider` | the state machine in §7.6 |
| `routerProvider` | `Provider<GoRouter>` | depends on onboarding + bootstrap |
| `mpStatsProvider` / `mpBalanceProvider` | `StreamProvider` / `Provider` | balance, level, streak, Vishram, today |
| `mpAwardProvider` | `NotifierProvider` | **the only write path** to the ledger |
| `todayProgressProvider` | `Provider` | ring: earned / goal |
| `feedControllerProvider` | `NotifierProvider.autoDispose` | paging, dwell timer, speed-scroll, checkpoints |
| `verseStateProvider` | `StreamProvider.family` | saved/seen per verse |
| `sankalpTodayProvider` / `yatraProgressProvider` | `StreamProvider` | today's promise, chapter unlocks |
| `mannSessionProvider` | `AsyncNotifierProvider` | compose → retrieve → result |
| `coachMarksProvider` | `NotifierProvider` | 4 marks, dismissed once |

**Naming:** `xxxProvider`, `XxxNotifier`, `XxxState`. `autoDispose` only for route-scoped notifiers, never repositories.

**Optimistic MP, and why the ledger stays in one place.** Three invariants:
1. The ledger is append-only and is the only stored number. `balance` is `SUM(delta)`; `user_stats` is a cache rebuilt from the ledger, never incremented independently.
2. One writer: `MpAwardNotifier.award()` is the only function that appends a row.
3. Optimism is an overlay, never a second balance.

```dart
Future<MpAwardOutcome> award(MpEventDraft draft) async {
  final key = draft.idempotencyKey;
  if (state.pendingByKey.containsKey(key)) return MpAwardOutcome.duplicate;

  final ctx = await _ledger.loadContext(draft, _clock());
  final preview = MpRules.preview(draft.toEvent(), ctx);
  if (preview is MpReject) return MpAwardOutcome.rejected(preview.reason);

  state = state.withPending(key, preview.delta);        // UI jumps by the CAPPED delta
  try {
    final decision = MpRules.evaluate(draft.toEvent(), ctx);
    await _ledger.append(LedgerEntry.from(decision, ruleVersion: MpRules.ruleVersion));
    return MpAwardOutcome.awarded(decision.delta);
  } finally {
    state = state.withoutPending(key);                  // the stream now carries the row
  }
}
```

`preview.delta == evaluate.delta` because both call the same pure function — so the optimistic number **never ticks down**. That is the whole reason caps live in `MpRules` and not in the DAO. The real duplicate guard is `UNIQUE(user_id, idempotency_key)` in SQLite, not Dart timing.

### 12.4 The design system in Flutter

| Token family | Mechanism | Why |
|---|---|---|
| Colours | `ThemeExtension<AppColors>` | must swap with `ThemeMode`; a const class needs `Brightness` checks at every call site |
| Type metrics | `const class AppType` (colour-free) | sizes/heights/weights never change between themes — only colour does |
| Devanagari styles | `ThemeExtension<AppDevText>` | `TextTheme`'s 15 slots are named for Latin roles; mapping shloka/Hindi-UI/IAST onto them is a lie that costs a rename at week 6 |
| Spacing, radii, borders, shadows, durations | plain `abstract final class` | compile-time constants; an extension adds a `Theme.of` lookup for zero benefit |

Field naming: the eight brand names stay untranslated (`patra`, `bhoj`, `kesar`, `sindoor`, `swarna`, `masi`, `ratri`) because they are shared vocabulary with the designer; everything semantic gets an English name (`ink`, `inkMuted`, `hairline`, `success`, `danger`). **No `Color(0xFF…)` outside `app_colors.dart`.**

**`ColorScheme.fromSeed` is removed.** It runs the M3 tonal-palette algorithm over one seed and desaturates toward neutral: `#C2601C` becomes muted brown, `#6E1F1A` becomes grey-rose, and the identity dies. It also generates 30 roles you don't use, each free to drift on a Flutter upgrade. Use an explicit `ColorScheme(...)` filled from the token set, and strip Material's soft elevation globally (`cardTheme.elevation = 0`, `appBarTheme.elevation = 0`, `splashFactory: NoSplash.splashFactory`).

**The signature widget.** `HardShadow` paints the offset rect as a *sibling* in a `Stack` (not a `BoxShadow`), so the decorated child stays opaque and cacheable, and animating the press state is a position change, not a mask re-raster.

```dart
class Plate extends StatelessWidget {
  const Plate({this.color, this.borderColor, this.borderWidth = AppBorder.b,
               this.radius = AppRadius.sm, this.shadow = AppShadow.s5,
               this.padding = const EdgeInsets.all(AppSpace.s20), required this.child});
}
```

**The performance trap, precisely.** `BoxShadow(blurRadius: 0)` is genuinely cheap. The traps are: (1) any `blurRadius > 0`, which allocates a mask filter and a raster pass; (2) `Material(elevation:)` / `Card` / `PhysicalModel`, which go through `drawShadow` on a `Path` and render a *soft* shadow that contradicts the style — hence `elevation: 0` globally; (3) `ClipRRect(antiAliasWithSaveLayer)`, `BackdropFilter` or `Opacity` on a full-bleed card, which force `saveLayer` on a 1080×2400 subtree. Draw the border as a `Border`, never a clip, and pre-mix translucency.

### 12.5 Typography and fonts

**Bundle the fonts. Do not ship `google_fonts`.**

| | `google_fonts` | bundled |
|---|---|---|
| offline first launch | fails — renders in the platform fallback, then reflows when the download lands | guaranteed, byte-identical |
| cold start | async work on the critical path or a visible flash | zero |
| share-card determinism | no | yes |

A runtime font fetch is exactly the bug this app's users will hit on a train in Bihar, and it corrupts the share card's output. All six families are OFL-1.1 — redistribute inside the APK, keep `assets/fonts/OFL.txt`, credit in the licences screen.

```yaml
flutter:
  assets:
    - assets/verses/gita_seed.json
    - assets/fonts/OFL.txt
  fonts:
    - family: Archivo
      fonts: [{asset: assets/fonts/Archivo-Variable.ttf}]        # wght 400–900
    - family: InstrumentSans
      fonts: [{asset: assets/fonts/InstrumentSans-Variable.ttf}]  # wght 400–700
    - family: IBMPlexMono
      fonts: [{asset: assets/fonts/IBMPlexMono-Regular.ttf, weight: 400},
              {asset: assets/fonts/IBMPlexMono-Medium.ttf,  weight: 500},
              {asset: assets/fonts/IBMPlexMono-SemiBold.ttf, weight: 600}]
    - family: TiroDevaSanskrit
      fonts: [{asset: assets/fonts/TiroDevanagariSanskrit-Regular.ttf}]
    - family: TiroDevaHindi
      fonts: [{asset: assets/fonts/TiroDevanagariHindi-Regular.ttf}]
    - family: NotoSansDevanagari
      fonts: [{asset: assets/fonts/NotoSansDevanagari-Variable.ttf}]
```

Subset before committing — the single biggest APK win:

```bash
pyftsubset TiroDevanagariSanskrit-Regular.ttf \
  --unicodes="U+0900-097F,U+1CD0-1CFF,U+200C-200D,U+0020-007E,U+2018-201D,U+0964-0965" \
  --layout-features="kern,liga,locl,abvm,blwm,ccmp,mark,mkmk,calt" \
  --output-file=assets/fonts/TiroDevanagariSanskrit-Regular.ttf
```

**Never** subset away the Devanagari shaping features (`abvm`, `blwm`, `ccmp`, `mark`, `mkmk`) — that is the classic route to broken half-forms and misplaced matras.

**Warm the fonts on the splash frame.** Declared asset fonts load lazily on first use, so the first card otherwise renders in the system fallback and then jumps. Render four invisible 4 sp `Text` widgets (one per family) on the splash `build`.

**Shloka style and the accessibility floor:**

```dart
static const TextStyle shloka = TextStyle(
  fontFamily: 'TiroDevaSanskrit',
  fontFamilyFallback: ['TiroDevaHindi', 'NotoSansDevanagari'],
  fontSize: 28, height: 1.55,
  leadingDistribution: TextLeadingDistribution.even,
  letterSpacing: 0, fontWeight: FontWeight.w400,
  // colour applied by AppTheme, never here
);
```

Two levels of `textScaler` clamping: the app root clamps 1.0–2.0, and the card wraps only its Devanagari block at 1.0–1.8 so a 2.0× user cannot push a five-line shloka past the fold. **Never** wrap the shloka in `FittedBox` or `AutoSizeText` — shrinking sacred text is a design failure and breaks the 20 sp floor.

### 12.6 Routing

`go_router` with `StatefulShellRoute.indexedStack` so each tab keeps its own `Navigator` and state (route tree in §6.3).

**Onboarding is not a place you can go back to** — three mechanisms, all required:

```dart
redirect: (context, state) {
  final boot = ref.read(bootstrapProvider);
  if (boot.isLoading) return null;
  final onboarded   = ref.read(onboardingProvider).completed;
  final inOnboard   = state.matchedLocation.startsWith('/onboarding');
  final isShareLink = state.matchedLocation.startsWith('/shloka/') &&
                      state.uri.queryParameters['src'] == 'share';

  if (!onboarded && !inOnboard && !isShareLink) return Routes.onboarding;
  if (onboarded && inOnboard) return Routes.shloka;   // ← the guard
  return null;
}
```

1. `context.go(Routes.shloka)` on completion — replace, never push.
2. The redirect guard runs on *every* navigation including back gestures.
3. Onboarding lives outside the shell, so no `indexedStack` branch holds it.

Deep links beat onboarding (a share recipient is a new user; a shloka is the best first impression), but we set `skippedByDeepLink = true` so the language sheet is offered after the second card.

**Expand sheet implementation.** `DraggableScrollableSheet(expand: false, initial: 0.58, min: 0.46, max: 0.96, snap: true)` wrapping **one `CustomScrollView`** whose slivers are swapped by tab index. The trap: a `TabBarView` inside a `DraggableScrollableSheet` gives each tab its own controller, which then fights the sheet's `ScrollController` — the sheet either won't drag or won't expand. `TabBar` for chrome only, swap slivers, keep one controller.

### 12.7 Data layer

**`Verse` model** (`domain/models/verse.dart`, hand-written `fromJson`, no `json_serializable` — it is one model and the parser must throw typed errors naming the offending verse):

`id` (`"3.21"`) · `chapter` · `number` · `yogaName` · `sanskrit` (+ `padas`) · `iast` · `meaningHi` · `meaningEn` · `meaningHiFull` · `meaningEnFull` · `wordMeanings[]` (`word`, `root`, `meaningHi`, `meaningEn`) · `speaker` · `listener` · `context` · `lessonHi` · `lessonEn` · `emotionTags[]` · `situationTags[]` · `tagWeights` (optional, week 2) · `audioChantUrl` (`""` in week 1) · `illustrationId` (`""` in week 1) · `difficulty` (1–3) · `adviceSafe`.

Reconciliation with blueprint §14: the plan's JSON schema stays **the contract** (it is what the content owner writes against today); `meaningHiFull/EnFull` and `tagWeights` are **optional** fields the parser tolerates as absent, so the file can grow into §14 without a code change. **Drop `embedding`** (a week-2 server artifact, never a bundled asset) and **drop the `lessons` table** (week-1 lessons are an ordered `verseIds` list inside the same asset). `adviceSafe = false` on Ch 1 war passages and varna passages — that flag is the retrieval gate.

**Asset loading.** `rootBundle.loadString` → `compute(buildCatalogFromJson, raw)` for parse + tokenise + idf. Parsing 108 verses is 15–25 ms on a flagship and 3–5× that on a Redmi 9A; together with indexing it is a visibly janky first frame. Cache in the repository *and* in a `keepAlive` provider. No disk cache — assets are versioned with the APK. Parse validation: unique ids, `id == "$chapter.$number"`, non-empty tags, `difficulty ∈ 1..3`, throwing `VerseParseException(verseId, field)` on the first failure. Fail loudly in debug; a mystery empty tag list in week 3 is worse.

**Drift schema** (`data/db/tables.dart`, epoch-ms INTEGER UTC):

| Table | Key columns |
|---|---|
| `mp_ledger` | `id`, `userId` (`'local'`), `ts`, `eventType`, `delta`, `refType`, `refId`, `dayBucket`, `idempotencyKey`, `ruleVersion`, `source`, `createdAt` — `uniqueKeys: [{userId, idempotencyKey}]` |
| `user_stats` (cache) | `mpTotal`, `mpSpent`, `level`, `streakCurrent`, `streakBest`, `streakLastDay`, `vishramBanked`, `vishramMonthKey`, `vishramUsedThisMonth`, `weeklyDepthMp` |
| `verse_state` | `firstSeenAt`, `views`, `saved`, `savedAt`, `lastSeenAt`, `dwellMsTotal`, `note`, `quizSeen`, `quizCorrect`, `srsDueAt` |
| `sankalps` | `dayBucket`, `text`, `source` (`mann`/`verse`), `sourceId`, `remindAt`, `status` (`open/done/partly/notToday/missed`), `checkedInAt` |
| `mann_entries` | `inputMode`, `transcript`, `moodChip`, `emotions`, `situations`, `riskLevel`, `verseId`, `altVerseIds`, `why`, `actions`, `modelVersions`, `feedback`, `deletedAt` |
| `view_events` | `verseId`, `startedAt`, `endedAt`, `dwellMs`, `qualified` — 7-day retention |
| `quiz_attempts` | `scopeId`, `verseId`, `chosen`, `correct`, `msToAnswer`, `ts` |

Deliberate non-choices: **no separate `saved_verses` table** (blueprint already models saving as `verse_state.saved`; a second table is a second source of truth and a sync bug); `source` on the ledger is the server-migration seam; `rule_version` lets week-2 rules coexist with week-1 rows; `dayBucket` is a **string** because it is already timezone-resolved, it is what every cap query filters on, and it makes the midnight-rollover bug impossible to write by accident.

Indexes on `(userId, dayBucket, eventType)`, `(userId, ts)`, `view_events.startedAt`, `(userId, dayBucket)` for sankalps.

**Migrations.** `schemaVersion = 1`, no migrations in week 1, but dump `test/drift/schema.json` on Day 1 so week 2 has a baseline to diff. `PRAGMA foreign_keys = ON` and `journal_mode = WAL` (the append path runs while the UI reads, and Android kills processes aggressively).

**Ledger immutability by omission:** `MpLedgerDao` exposes `append`, `sumFor`, `countFor`, `watchRecent`, `sumByGroup` — and **no** `update`/`delete`, with a test that greps for their use.

**Append-only + idempotency + day buckets.** Every point must be auditable and re-computable after a rules change; a mutable balance cannot answer "why do I have 480?" and cannot reconcile with a server.

| Action | Key | Collapses |
|---|---|---|
| read verse | `read:{verseId}:{dayBucket}` | re-reading the same verse today = 0 |
| expand | `expand:{verseId}:{dayBucket}` | Katha then Jeevan on one verse = one award |
| checkpoint | `checkpoint:{checkpointId}` | re-answering = 0 |
| lesson | `lesson:{lessonId}` | replay = 0 |
| Mann entry | `mann:{entryId}` | one per entry, capped 2/day |
| Sankalp | `sankalp:{sankalpId}:{status}` | re-tapping check-in = 0 |
| goal | `goal:{dayBucket}` | once per day, ever |
| streak | `streak:{days}` | once per milestone, ever |

Keys are minted by the caller, never the engine (`MpRules` stays pure, no uuid dep), and are unique in SQLite — so "18 rapid taps on Save" produces one row even if the UI is wrong.

`MpDay.bucket(utc, offset)` formats `utc.add(offset)` as `YYYY-MM-DD` by hand (no `intl`). The `offset` is captured per event, so a user flying to Dubai keeps a coherent day. The **event's own timestamp** decides its bucket, not "now" at write time: a read that started at 23:59:58 and qualified at 00:00:04 belongs to the new day, and that is tested explicitly.

**Where caps are enforced — the seam.**

| | Week 1 (offline) | Week 2+ (server-authoritative) |
|---|---|---|
| Cap arithmetic | `MpRules` on device against `MpContext` from Drift | same function *shape* re-implemented server-side; client keeps a copy only for optimistic preview |
| Write | client appends `source='client'`, `rule_version=1` | client appends an `Outbox` row; server appends `source='server'`; client mirrors |
| What counts | all rows | only `source='server'` rows (`isAuthoritative == true`), plus a transient overlay |
| Rejection | `MpReject` → nothing written | server returns `{key, accepted:false, reason}` → client drops the overlay and shows the reason |

That is why `isAuthoritative` and `source` exist on day one: flipping the flag and adding an Outbox loop is a week-2 change inside `data/`, while `MpRules`, every screen and every test stay put. The rule that makes it safe: **the client never adds to a server-authoritative balance — it only overlays until the server answers.**

### 12.8 The MP rule engine

Pure Dart, zero dependencies, no Flutter, no `intl`, no `uuid`.

```dart
abstract final class MpRules {
  static const int ruleVersion = 1;
  static const Map<MpEventType, RuleSpec> table;
  static MpDecision evaluate(MpEvent e, MpContext c);   // authoritative, pure
  static MpDecision preview(MpEvent e, MpContext c) => evaluate(e, c);
  static const List<LevelDef> levels;                  // 7 levels, blueprint §08
  static int levelFor(int mpTotal);
  static int levelFloorMp(int mpTotal);
}
```

`MpDecision` is `sealed` (`MpAward` | `MpReject(reason, detail)`), so an exhaustive `switch` in a future server handler is compiler-checked. `MpContext` is a flat value object with no dependencies, so it can come from a Drift query (week 1) or a request body (week 2). `RuleSpec` carries `mp`, `group`, `capStyle`, `cap`, `scope`, `requiresMinDwell`, `blockedByFeedPause`.

Week-1 table:

| Event | MP | Cap | Style | Scope | Note |
|---|---|---|---|---|---|
| `verseRead` | +2 | 20 | mpTotal | day | needs `dwellMs ≥ 6000`; blocked by feed pause |
| `expandOpen` | +3 | 10 | eventCount | day | one per verse per day |
| `checkpointCorrect` | +5 | — | — | day | one per checkpoint id |
| `yatraLesson` | +20 | — | — | lifetime | one per lesson |
| `perfectQuiz` | +10 | — | — | lifetime | one per lesson |
| `chapterComplete` | +100 | — | — | lifetime | one per chapter |
| `mannEntry` | +15 | 2 | eventCount | day | `riskLevel == critical` ⇒ `crisisExcluded` |
| `sankalpDone` | +25 | 1 | eventCount | day | |
| `sankalpPartly` | +10 | 1 | eventCount | day | |
| `reflectionNote` | +8 | 3 | eventCount | day | |
| `dailyGoalMet` | +15 | 1 | eventCount | day | |
| `streakMilestone*` | +50/150/500/1008 | 1 | eventCount | lifetime | |
| penalties | — | — | — | — | **not registered in week 1** |

The blueprint mixes "20 MP/day" (a delta-sum cap) with "10 times" (an event-count cap). A naive `SUM(delta) < 20` on the expand rule allows 6 opens instead of 10. That distinction is why `capStyle` is an enum and not a comment — it is the most likely arithmetic bug of the week.

Protective rules live in the engine, never the UI: **mood never deducts** (no rule reads `meta['mood']`; `mannEntry` pays +15 for grief exactly as for joy); **honest "not today"** is not in the table, so it rejects with `not_today_counts_zero` and the streak is *held*; **level floor** clamps any future negative so `mpTotal + delta ≥ levelFloorMp`; **speed scroll** (5 views each < 2000 ms apart) sets `feedPausedUntil = last + 10 min` and rejects only `blockedByFeedPause` rules — checkpoints, lessons and Mann are unaffected; **crisis exclusion** refuses any event carrying `riskLevel == critical` before consulting the table.

**Tests that must exist** (fixed clock, offset +05:30): cap_mpTotal · cap_eventCount · idempotency same key · idempotency across midnight · sad mood pays the same · not-today pays 0 and holds · speed-scroll pauses · speed-scroll boundary (exactly 2000 ms is **not** fast) · pause expiry · Vishram two free/month · Vishram earned 1 per 7 days max 5 banked · Vishram consumed before reset · streak no double increment · streak consecutive · streak gap resets to 1 · midnight rollover · same instant different timezone · level floor clamps · reject-reason enum stable · rule version stamped · **`preview_equalsEvaluate` property test over 100 random contexts** — the last one protects the "points never tick down" promise.

### 12.9 Feed performance

`PageView.builder` with `PageScrollPhysics`, `allowImplicitScrolling: true`. PageView gives exact paging, native snap, and a controlled current±1 window in ~40 lines; a `CustomScrollView` gives the same with more places to get scroll position wrong. `allowImplicitScrolling` is required — without it TalkBack can never reach the next card on Android and the first swipe shows a blank frame.

Rules for 60 fps with full-bleed cards and heavy Devanagari:

1. `const` leaf widgets (`CardHeader`, `CardRail`, `Stamp`, `TagChip`); only `FeedPage` rebuilds.
2. `RepaintBoundary` around exactly two things: the art layer and the MP rail. Both repaint without re-laying-out the Devanagari, which is the expensive part.
3. No `Opacity`, `BackdropFilter`, `ShaderMask` or `ClipRRect` on the card. The deckle edge is a pre-rendered PNG or a painter path.
4. **One `Text` per layer.** The shloka is a single `Text`, never a `Column` of per-line texts — that multiplies shaping work and breaks `height` leading.
5. Never animate `textScaler`; it re-runs shaping every tick.
6. No `MediaQuery.of(context)` inside the card — it subscribes to keyboard insets too. Use `sizeOf` / `paddingOf` / `textScalerOf`.

**Card state without keeping card trees alive.** `PageView` disposes off-screen children, so a `State` inside `ShlokaCard` (dwell timer, burst position) dies on a fast swipe. The wrong fix is `AutomaticKeepAliveClientMixin` — it pins three full card subtrees, each with multi-line Devanagari, in memory and the raster cache. The right fix: hoist state into a light `FeedItemController extends ChangeNotifier` (~200 bytes, no `BuildContext`), keep a ±2 window, and let each page listen with `ListenableBuilder`.

**The dwell timer.** One timer for the whole feed, owned by `FeedController`, not one per card. Cancel on page change, on `didChangeAppLifecycleState != resumed`, and when `ModalRoute.isCurrent == false` — a card behind a sheet is not being read. Record the `view_event` whether or not it qualified, so speed-scroll detection has data for sub-6s swipes. The award is idempotent per `(verse, dayBucket)` even if the timer fires twice.

**Not rebuilding the card on MP changes.** A provider that changes on every read may only be watched inside a ≤ 48 dp leaf. Balance is watched **only by `MpPill`**, which sits in the header outside the `PageView`. The card's own "+2" badge reads a local integer on `FeedItemController`. `saved` is a `family` scoped to one verse. This single rule is the difference between a smooth feed and a stutter on every award.

### 12.10 Motion implementation

| Effect | Widget choice | Why |
|---|---|---|
| Lotus burst | `AnimationController(480ms)` + `CustomPainter` (6 petals, staggered) | sequenced animation with delays; a Lottie/Rive asset adds a dependency and a handoff for 40 lines of math. Inserted only while playing, inside a rail-sized `RepaintBoundary` — so it paints on 200×200 while a 1080×2400 card sits untouched. |
| Coin glint | `TweenAnimationBuilder<double>` | single value, single direction, no coordination |
| HardButton press | `AnimatedContainer` 90 ms on shadow offset + matching translate | reproduces the HTML `:active` rule exactly |
| Sheet spring | route `transitionAnimationController` + `DraggableScrollableSheet` | physics are built in |
| Reduced motion | `AppMotion.resolve(context, duration)` returns `Duration.zero` when `MediaQuery.disableAnimationsOf(context)` | one gate, every animation |

Under reduced motion the burst becomes a static gold ring flash, the glint jumps to its end state, the sheet opens instantly, and haptics still fire. Because nothing here needs `saveLayer`, reduced motion is a duration change, not a second code path.

### 12.11 Mann Darpan v0

Three stages, in this order — **crisis gate, normalise, score**. The order is a safety requirement.

**1. Crisis gate (always first).** Case- and space-normalised substring match against a deliberately over-triggering phrase list in four registers: English (`suicide`, `kill myself`, `end my life`, `no reason to live`, `cut myself`, `self harm`), Hinglish (`khudkhushi`, `aatmhatya`, `marna chahta`, `mar jaana chahta`, `jeena nahi chahta`, `jeene ka mann nahi`), Devanagari (`आत्महत्या`, `मरना चाहता`, `जीना नहीं`), and abuse (`rape`, `molest`, `beats me`, `hits me`, `balatkar`, `maar peet`). No stemming, no synonym expansion, **no negation parsing** — false positives are the correct failure mode. On hit: short-circuit everything, write a `MannEntry` with `riskLevel = critical` and `awardedMp = 0`, open `/mann/crisis`, never call the retriever, never touch `MpRules` (which independently rejects critical events as a second line of defence).

**2. Normalise.** Lowercase, strip punctuation, collapse whitespace, strip IAST marks. Devanagari is transliterated to Latin by a small IAST↔Devanagari map so `गुस्सा` and `gussa` reach the same lexicon key — one lexicon, not two. The Hinglish lexicon is a hand-written `const Map` of ~120 surface forms onto the ~40 emotion + ~60 situation tags (`tension`, `pareshan`, `ghabrahat`, `stress`, `darr` all reach `anxiety`). It is ~150 reviewable lines, which matters because the content owner will want to edit it. Stemming is deliberately dumb (strip `ing/ed/es/s`, Hindi plurals `ें/ों`, verb endings, plus a small irregular map). Stopwords cover English and Hinglish particles (`hai`, `ho`, `ka`, `ki`, `mein`, `aur`, `toh`, `na`, `ko`, `se`, `par`).

**3. Score** — `0.5 × tagOverlap + 0.4 × keywordSimilarity + 0.1 × freshness`:

- `tagOverlap = |queryTags ∩ verseTags| / |queryTags|` — **recall-weighted, not Jaccard.** A query yields 1–4 tags, a verse carries 3–6; Jaccard punishes a good single-tag match against a broad verse.
- `keywordSimilarity` = cosine of tf·idf over `lesson + context + meaning` tokens. `idf` is computed once at catalog build.
- `freshness` = 1.0 unseen, else `1 − clamp(daysSince / 30, 0, 1)`.
- **Exclusions before scoring**, not after: `adviceSafe == false`, and the last 3 shown. A crisis-adjacent verse can never leak in as a "top 3".
- **Deterministic tie-break:** score desc, then chapter asc, then number asc. Required for the 10-input fixture and for share-card reproducibility.
- Returns top 3 plus a **2-sentence "why"** assembled from tag-seeded templates — no generation in week 1. Week 2's LLM replaces the template, not the interface.
- Cost: ~0.3 ms over 108 pre-tokenised verses. Keep it synchronous.

**Voice, stubbed behind an interface.** `AudioCapturer` exists and is implemented by `TextOnlyCapturer` (throws `VoiceUnavailable`); the mic renders with "Voice coming soon" and text is the primary path. **No `RECORD_AUDIO` permission is requested in week 1** — no dead permission prompts. Week 2 swaps in `RecordAudioCapturer`: 2-minute cap with a countdown ring at 15 s left, `getTemporaryDirectory()/mann/{uuid}.m4a`, AAC-LC 16 kHz mono, delete in a `finally`, sweep orphans on start, never write audio to permanent storage. Building the interface now means week 2 is one class plus a provider override, while the crisis gate and retriever — the parts carrying the legal and product risk — are already tested.

### 12.12 Onboarding implementation

`enum OnboardingStep { splash, language, intent, goal, coachMarks, done }`, held in `OnboardingNotifier extends Notifier<OnboardingState>`, driven by a single `AnimatedSwitcher` over the step body — **not a `PageView`**, which would let the user swipe past the intent gate.

Persistence split is §7.7. `markCardSeen()` is the only incrementer of `cardsSeen`, called from `_onPageChanged` when `page > _seenHighWater`; a debounced fire-and-forget prefs write.

**Deferred OTP trigger.** `shouldPromptOtp => cardsSeen >= 5 && !otpPromptShown`, or the first save. Set `otpPromptShown = true` **before** navigating, so a failed push cannot loop. The sheet never blocks the feed; a second prompt happens only on the next save, never on a timer; after two dismissals it stops for the session and only re-prompts on a value moment.

**Coach marks: `OverlayEntry`, not `showcaseview`.** One entry containing a `CustomPaint` scrim with four even-odd cut-outs, four positioned callouts in Stamp styling, and a full-screen dismiss gesture. Four targets, ~120 lines, no dependency, and `Overlay.of(context, rootOverlay: true)` puts it above the nav bar for free. Dismissed on first swipe, tap outside, or 12 s. Scrim is `ExcludeSemantics`; each callout is real text.

**Notification priming.** Never cold, never on the goal screen. The goal step writes a *preference* (`remindAtMinutes`); after the first qualified read an in-app rationale plate appears once — *"Roz ek shloka, tumhare waqt par. Reminder bhejein?"* — and only `Haan` calls `requestPermission()`. Denial sets `notificationsEnabled = false`, delivers the morning slot in-app only, and never re-asks (Settings offers the deep link). Scheduling uses `AndroidScheduleMode.inexactAllowWhileIdle` with `matchDateTimeComponents: time`; exact alarms need `SCHEDULE_EXACT_ALARM`, which Play reviews and which a 7 a.m. nudge does not justify. Max 2/day and nothing 22:00–07:00 is validated in `NotificationService.schedule`, not the UI.

**Cold start, under 30 seconds** (target ~4 s, because 30 s is a ceiling and a slow first run is the activation killer):

| Phase | Budget | Mechanism |
|---|---|---|
| native splash → first Flutter frame | 600–1200 ms | native splash background `#F5ECD9` so there is no white flash and no double splash |
| `main()` | **0 ms of async** | `ensureInitialized(); runApp(ProviderScope(...))` — no `await`, no prefs, no DB, no JSON |
| bootstrap (prefs + settings) | 3–15 ms | Drift opens **lazily**, on first query |
| catalog load + isolate parse | 80–250 ms, off the UI isolate | starts after the splash body is already on screen |
| first card painted | ≤ 1.5 s | skeleton cards swap in; the feed mounts before the catalog finishes |

Concrete promises: **no network on this path** — not one HTTP call, not even a font check. The Flutter splash shows only if bootstrap exceeds 400 ms, in the same parchment, so the handoff is invisible. Up to 3 skeleton plates render if the catalog isn't ready, which removes parsing from the perceptual critical path entirely. Selecting a language re-renders the feed without a reload because both languages live in the same `Verse` object.

### 12.13 Testing

| Kind | Belongs here | Must not |
|---|---|---|
| **Unit** | `MpRules`, `StreakEngine`, `MpDay`, `CrisisGate`, `TextNormalizer`, `MannRetriever`, verse parse, DAO queries on `NativeDatabase.memory()` | anything needing `BuildContext` or a real plugin |
| **Widget** | feed paginates and awards once; Devanagari renders; expand sheet opens/switches/closes with no overflow at 320×568; onboarding advances and blocks; MP pill updates; checkpoint at page 7 | pixel appearance; animation timing beyond `pumpAndSettle`; platform channels |
| **Golden** | **none in week 1** | Devanagari goldens (see below) |

Week-1 list: the 20 engine tests + property test · `crisis_gate_test` (20 crisis phrases in 4 registers, 20 benign near-misses, embedded phrase in a long benign sentence, Devanagari, and "crisis path awards 0 and writes no `verseRead` row") · `mann_retriever_test` (10 fixtures asserting expected top-1, determinism, `adviceSafe == false` never in top 3, `excludeIds`, gibberish → graceful empty) · `verse_parse_test` · `mp_ledger_dao_test` (duplicate insert returns `false` with 1 row; `loadContext` handles both cap styles; `rebuildStats` matches incremental after 50 events; no update/delete surface) · `architecture_test` · widget tests above.

**No goldens in week 1.** `flutter test` loads no app fonts by default, so a golden captures the fallback font; Devanagari shaping shifts a pixel on any Flutter/Skia bump; and goldens are platform-specific. Cover layout with widget tests asserting `tester.takeException()` is null (catches `RenderFlex overflowed`) plus a manual device pass on Day 2 and Day 7. Add `alchemist` goldens in week 2, once the design stops moving daily.

**CI additions** to `.github/workflows/build.yml` (keep `FLUTTER_VERSION` pinned):

```yaml
- run: flutter pub get
- run: dart format --output=none --set-exit-if-changed lib test
- run: dart run build_runner build --delete-conflicting-outputs
- run: git diff --exit-code -- 'lib/data/db/*.g.dart'   # stale .g.dart = runtime crash on device
- run: flutter analyze
- run: sudo apt-get update && sudo apt-get install -y libsqlite3-dev  # Drift needs the unversioned .so
- run: flutter test --reporter expanded
```

Turn on `strict-casts` and `strict-raw-types` in `analysis_options.yaml` on day 0 — JSON parsing is exactly where implicit `dynamic` downcasts hide. Plugins (`record`, `flutter_local_notifications`, `share_plus`) throw `MissingPluginException` in `flutter test`; every test touching them must inject a fake through the composition root. If a test needs a plugin, that is a design smell.

### 12.14 Packages

Caret constraints always (`^x.y.z`); commit `pubspec.lock` so CI resolves identically.

**The UI-first pass ships three dependencies, not the full table below**: `flutter_riverpod ^3.4.0`, `go_router ^18.1.0`, `shared_preferences ^2.5.0`. Drift, notifications and `record` are deliberately absent until there is data to persist and a permission worth asking for — that keeps `flutter pub get` fast, `flutter test` plugin-free, and the Android build untouched. The table is the target for the week, not the current state.

| Package | Verdict | Constraint | Reasoning |
|---|---|---|---|
| `flutter_riverpod` | confirm | `^3.0.0` | `Notifier`/`AsyncNotifier` are the supported API |
| `go_router` | confirm | `^16.0.0` | `StatefulShellRoute.indexedStack` is the shell; deep links |
| `drift` + `drift_dev` | confirm | `^2.28.0` | typed queries, streams, append-only ledger |
| `drift_flutter` | confirm | `^0.2.0` | wraps `path_provider` + `NativeDatabase` in one call |
| `sqlite3_flutter_libs` | confirm | `^0.5.0` | ships the per-ABI `.so`; without it Android has no sqlite3 |
| `path_provider` | confirm | `^2.1.0` | share-card PNGs, week-2 audio |
| `shared_preferences` | **add** | `^2.3.0` | boot flags must resolve before SQLite opens |
| `share_plus` | confirm | `^11.0.0` | the viral loop; needs `sharePositionOrigin` on iPad |
| `flutter_local_notifications` | confirm | `^19.0.0` | only supported 2-daily path; needs desugaring + compileSdk 35 |
| `timezone` + `flutter_timezone` | **add** | `^0.10.0` / `^4.0.0` | `zonedSchedule` needs `TZDateTime`; `tz.local` must be set explicitly |
| `intl` | confirm | `^0.20.0` | plurals/date labels in UI — **never inside `domain/`** |
| `uuid` | confirm | `^4.5.0` | ledger, Sankalp, Mann ids (presentation/data only) |
| `build_runner` (dev) | confirm | `^2.5.0` | Drift codegen |
| `record` | add now, UI gated | `^6.0.0` | building the interface now de-risks week 2; flag off so no test path reaches it |
| `just_audio` | **defer** | — | zero audio files in week 1; adding a plugin channel + manifest change for an untested path is a bad trade |
| `google_fonts` | **replace** | — | bundle OFL files; runtime download breaks offline-first and share-card determinism |
| `mocktail`, `freezed`, `json_serializable`, `equatable`, `riverpod_generator` | skip | — | 5 handwritten fakes beat mocks; three models need `==` |
| `lottie`, `rive`, `flutter_svg`, `showcaseview`, `flutter_animate`, `cached_network_image` | skip | — | each adds a vocabulary or dependency for something already solved in ~100 lines |
| `supabase_flutter`, `sentry`, `posthog`, `revenuecat`, `flutter_secure_storage` | defer | — | week 2+; network init has no place on the cold-start path |

### 12.15 Android build

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<!-- RECORD_AUDIO is NOT added in week 1 -->
```

```kotlin
// android/app/build.gradle.kts
compileSdk = 35            // flutter_local_notifications 19 requires ≥35
minSdk = 24                // Flutter floor; record needs ≥23
targetSdk = 35
compileOptions { isCoreLibraryDesugaringEnabled = true }   // or the release build fails on java.time
dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }
```

Also: the two `flutter_local_notifications` receivers (`ScheduledNotificationReceiver`, and the boot receiver with `BOOT_COMPLETED` / `MY_PACKAGE_REPLACED` / `QUICKBOOT_POWERON`) — **without them scheduled notifications silently never fire**. And `windowSplashScreenBackground` = `#F5ECD9` so the native splash matches.

**APK size (`--split-per-abi`, release):** engine ~8 MB · sqlite3 + Drift ~1.4 MB · six subset fonts **≤ 1.2 MB** · 108 verses ~120–180 KB packed · AOT code ~1.5–2.5 MB · icons ~400 KB → **≈ 12–14 MB arm64**. Fail the CI build above **16 MB**.

**Add dependencies one PR each**, in the order riverpod → go_router → drift stack → share → notifications → record, running `flutter build apk --split-per-abi` after every one. Stacking four plugin changes into one Day-6 merge is how the week gets lost.

### 12.16 Top technical risks

| # | Risk | Mitigation |
|---|---|---|
| 1 | **Devanagari renders wrong** (clipped matras, fallback on first frame, wrong face on an OEM) | bundle + subset with shaping features intact; `height: 1.55` + `even` distribution; warm-up on splash; **physical device test on Day 2, not Day 7**; widget test for overflow at 320×568 and 2.0× scale; never `FittedBox` |
| 2 | **MP double-award or cap bypass** on rapid swipes / double taps / process kill | deterministic keys + `UNIQUE(user_id, idempotency_key)` (the real guard, not Dart timing); single writer; WAL; stats rebuilt from the ledger; the 20-test list |
| 3 | **Cold start blows the 30 s promise** | zero awaits in `main()`; isolate parse; lazy Drift; prefs only on the boot path; matching native splash colour; skeleton cards; measure on a mid-range device Day 1 and Day 7 with `--trace-startup` |
| 4 | **Android/CI build breaks from plugins** | one dependency per PR, APK build after each; desugaring and compileSdk set before notifications land |
| 5 | **Scope beats the week** | the freeze list in §13; content is the real bottleneck — 27 verses on Day 1 beats 108 on Day 4 |

---

## 13. Week 1 build order, cuts, and open decisions

### Build order

| Day | Ship | Gate |
|---|---|---|
| 0 | deps (one PR each), folder tree, tokens, 5-tab shell, 27 seed verses | app boots into the shell; analyze + test green |
| 1 | design system, `Verse` model, repository, both themes | debug screen lists verses with correct Devanagari in light **and** Ratri |
| 2 | feed + expand sheet + coach marks | 60 fps offline swipe; sheet opens on a 320×568 phone without overflow |
| 3 | MP engine + ledger + checkpoints + Nitya completion | the 20 engine tests pass |
| 4 | Yatra Ch 1–3 + Sankalp + notifications | finish Ch 1 Lesson 1 end-to-end; notification fires on a device |
| 5 | Mann Darpan (text-first) + crisis gate + journal | 10 fixtures return the expected verse; crisis always bypasses |
| 6 | onboarding (real flow) + deferred OTP + share card | install → first shloka under 30 s; share renders at 1080×1920 |
| 7 | profile, accessibility pass, release build, tag `v0.1.0` | signed APK on a physical device; CI green; PR to `main` |

### Freeze list

**1 feed · 1 sheet with 3 tabs · 1 checkpoint shape · 3 chapters · 1 Sankalp shape · 1 Mann result layout · 1 share variant · 5 tabs.** Anything not on this list is week 2, however quick it looks on Day 5.

### Cut, and what ships instead

| Cut | Ships instead |
|---|---|
| chant/meaning audio | the rail's audio slot is **removed**, not disabled — three items, wider targets. Silence beats a lie. |
| Pro paywall | no upsell anywhere; the settings row does not exist |
| Sangha leagues / Sakha / Parivar | the honest preview screen (§8.11) |
| Ch 4–18 playable | visible, locked, real names, real verse counts, honest "opens in week 2/3" |
| widgets, focus lock, seasonal challenges | absent from nav and settings |
| real STT/LLM/TTS | local tag retrieval + keyboard; mic behind a flag |
| mood-trend chart | a plain "aapke 3 hafte" sentence until there are 14 days of data |
| multi-script rows | present, opening an honest "coming soon" sheet |
| tablet layouts | content max-width 480 dp, centred, letterboxed parchment |

### Fake it so it looks finished

| Missing | Fake |
|---|---|
| 60 commissioned illustrations | **six procedural parchment motifs** in `CustomPaint` — lotus, chariot wheel, conch, diya, peacock feather, kalash — chosen by `hash(verse.id) % 6`, 1 dp line art at 7–9% over `surfaceAged`, plus a per-chapter 3-stop gradient. ~200 lines, looks intentional, swaps to real art with no layout change. |
| share-card art slot | the same motif band at 100% inside a `field`-bordered 4:3 block, with an `m1` caption reserved for the artist credit |
| reward illustration | `IcLotus` at 64 dp in gold; the burst animation does the emotional work |
| badge art | a 40 dp gold circle + 2 dp mono glyph + 9 sp name — ten of them look like a set because the constraint is the system |
| Yatra map art | the dashed painter + nodes. At phone width this is genuinely better than a painted map. |
| onboarding illustration | none. Type, stamps, one verse. The ॐ at 64 sp is the illustration. |
| empty states | one motif at 30%, one line, one action |

**Definition of "looks finished":** every screen has a real empty state, a real loading state, a real error state, correct Devanagari at 200% scale, and at least one object with a hard shadow and one stamp — so the Day-7 screenshots look like the wireframes, not like a scaffold.

### Decisions taken this session

1. **Type families — decided.** **Archivo + Instrument Sans + IBM Plex Mono + Tiro Sanskrit + Tiro Hindi + Noto Sans Devanagari**, bundled as assets (six OFL families, ~3.1 MB un-subset). This departs from the PDF's nominated files but keeps its three voices; see §0.2 #3. Subsetting to ≤1.2 MB is a later polish step.
2. **Language step — decided.** Mandatory, one tap, no skip, with the source's "Step 1 of 3". It is the only onboarding screen the user cannot bypass.
3. **Haptic audio ambience — still open.** Tanpura drone and temple bell are out of week 1; the blueprint's *"off by default in public"* is recorded here as a permanent rule, not a scheduling detail.
4. **Mann Darpan free limit — still open.** 3 per week from day one, or unlimited until billing exists in week 9.

---

## 14. Build status

What exists on this branch, and what it was verified with.

| Surface | State | File |
|---|---|---|
| Design tokens (light + Ratri), type scale, motion, haptics | **built** | `lib/core/theme/` |
| `HardShadow`, `PaperPlate`, `HardButton`, `Stamp`, `ChoiceChipTag`, `MpPill`, parchment grain, six procedural motifs | **built** | `lib/core/widgets/` |
| 5-tab shell with the raised mic | **built** | `lib/presentation/shell/` |
| Onboarding: splash → language → intent → Nitya Path, with step counter and prefs persistence | **built** | `lib/presentation/onboarding/` |
| Feed: PageView, For You / Kram / Topics, rail, save, MP award, coach marks | **built** | `lib/presentation/feed/` |
| Shloka card with the full nine-part anatomy | **built** | `lib/presentation/feed/widgets/shloka_card.dart` |
| Expand sheet: Shabdarth / Katha / Jeevan, one scroll controller | **built** | `lib/presentation/feed/widgets/expand_sheet.dart` |
| Checkpoint card every seventh card | **built** | `lib/presentation/feed/widgets/checkpoint_card.dart` |
| Moksh Points wallet with an itemised ledger | **built** | `lib/presentation/mp/wallet_screen.dart` |
| Share-card composer: 9:16 canvas, three themes, four targets, deep link copy | **built** | `lib/presentation/share/share_card_editor.dart` |
| Sankalp create: pre-filled promise, 80-char counter, reminder chips | **built** | `lib/presentation/sankalp/sankalp_screen.dart` |
| Sankalp evening check-in: three equal answers, honest "aaj nahi hua" costs 0 | **built** | `lib/presentation/sankalp/sankalp_checkin.dart` |
| "Nitya Path complete" reward sheet | **built** | `lib/presentation/mp/daily_reward_sheet.dart` |
| Library with search, 18 chapters, real verse counts | **built** | `lib/presentation/library/` |
| Gita Yatra path with locked/done/current nodes | **built** | `lib/presentation/yatra/` |
| Mann Darpan idle (Ratri, breathing mic, mood chips) | **built** | `lib/presentation/mann/mann_screen.dart` |
| Mann Darpan result + Jeevan Path | **built** | `lib/presentation/mann/mann_result_screen.dart` |
| Crisis support | **built** | `lib/presentation/mann/crisis_screen.dart` |
| Sangha honest empty room | **built** | `lib/presentation/sangha/` |
| Profile: stats, badges, rows | **built** | `lib/presentation/profile/` |
| MP rule engine, Drift ledger, notifications, `record`, PNG export via `RepaintBoundary` | **not built** — next | — |
| Journal list, settings | **not built** — next | — |

**Verification on this branch:**

- `flutter analyze` → **No issues found** (Flutter 3.47.8 / Dart 3.13.7).
- `flutter test` → **46 tests pass**, covering: first-run routing, onboarding step counter, returning-user shell, feed layout at 360×800, paging, the expand sheet, 320×568 at 200% text scale with no overflow, save-and-award, the checkpoint on page 8, every screen at both sizes, the reward sheet, both crisis helpline numbers, and **14 golden renders** of the real screens with the bundled fonts loaded (`test/goldens/`).
- **Goldens are the design review artefact.** `test/goldens/{feed,sheet,onboarding,checkpoint,wallet,yatra,mann,result,crisis,library,profile,share,sankalp,checkin}.png` are rendered at 390×844 with Archivo, Instrument Sans, IBM Plex Mono, Tiro Sanskrit, Tiro Hindi, Noto Devanagari **and Material Icons** loaded — so they show what a phone shows, not a fallback font. Three defects were found this way and fixed: the coach plate covering the first pada, `ṇ`/`ṣ` rendering as tofu, and padas wrapping mid-line.
- **APK build not verified**: this machine's Android SDK has only `platform-tools` (no `platforms/`, no `build-tools/`) and `JAVA_HOME` points at a JDK that is not installed. That is an environment gap, not a code failure — but it means "builds on a device" is still unproven.

**Known gaps against the sources:** the journal list and settings are specified above and not yet rendered; the checkpoint quiz is hand-authored rather than drawn from the seed data; the feed's dwell timer is not yet wired to a real ledger; and the share card renders and previews but does not yet rasterise to PNG or invoke the system share sheet (§8.5 export path).

---

*Companion to `WEEK_1_EXECUTION_PLAN.md` and `DharmaScroll_Product_Blueprint.pdf`. Hand this and `gita_seed.json` to the Flutter dev; nothing else should be needed to build the week-1 visual layer.*
