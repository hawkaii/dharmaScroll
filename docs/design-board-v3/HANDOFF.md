# dharmaScroll design v3: Flutter handoff

Source of truth: `docs/design-board-v3/index.html` (open it, it animates). Approved by the owner.
Rules that never bend: no emoji, no red, no Krishna figure (symbols only), no quiz chips, no infinite scroll, points never go down.

## 1. Colour tokens (one file: `lib/design/tokens.dart`)

Dark ("Temple Night", default)

| Token | Hex | Use |
|---|---|---|
| bg | `#1A0F24` | screen |
| surface | `#2A1A38` | cards, sheets |
| raised | `#3A2548` | selected / pressed |
| line | `#FBEFD9` @ 12% | dividers, borders |
| ink | `#FBEFD9` | text (16.2:1) |
| mute | `#C9B2B8` | secondary text (9.3:1) |
| faint | `#8F7A8C` | labels, hints (4.7:1) |
| marigold | `#FFC247` | primary light, icons, active (11.5:1) |
| saffron | `#F28C28` | button depth, flame |
| gold | `#F7D58B` | Sanskrit text (13.1:1) |
| rose | `#E58BA3` | keep, joy, petals (7.5:1) |
| peacock | `#4FB3AB` | voice and listening only (7.4:1) |
| btnInk | `#2B1300` | text on buttons (10.9:1 on marigold) |
| btnA / btnB / btnEdge | `#FFC85A` / `#F28C28` / `#B8650C` | button gradient top, bottom, 3 px edge |
| glowA | `#F28C28` @ 22% | top glow on every screen |
| glowB | `#E58BA3` @ 10% | bottom glow |
| flame | `#FFB03B`, core `#FFF3CF`, dim flame `#6C4A2A` | diya |
| lampOff | opacity 0.45 on the diya | unlit streak lamp |

Light ("Ivory Dawn", Today screen only)

| Token | Hex |
|---|---|
| bg | `#FBF3E2` |
| surface / raised | `#F2E4C8` / `#EBD9B8` |
| line | `#2B1A33` @ 14% |
| ink | `#2B1A33` (14.7:1) |
| mute | `#6B5565` (6.1:1) |
| faint | `#7A6070` (5.1:1) |
| accent (icons, large type only) | `#B85A0B` (4.2:1) |
| goldText | `#8A5A00` (5.4:1) |
| glow | haldi `#F6B93B` @ 55% top, rose @ 18% bottom |
| button | same gradient as dark |

Mapping rule: build a `DharmaTheme` with two `ColorScheme`s. No widget may read a hex directly.

## 2. Type

Fonts (bundle as assets, declare in `pubspec.yaml`):

| Family | Role | Files |
|---|---|---|
| Noto Serif Devanagari | Sanskrit verses | `NotoSerifDevanagari-Regular.ttf` (add `-Medium` if verses look thin) |
| EB Garamond | meanings, titles, body | `EBGaramond-Regular.ttf`, `EBGaramond-Italic.ttf` (the board used `EBGaramond12-*.ttf` from the system) |
| Inter | labels, buttons only | `Inter-Regular.ttf`, `Inter-Medium.ttf`, `Inter-SemiBold.ttf` |

All three are open-licence (OFL). Use lining numerals.

| Style | Font | Size / line | Notes |
|---|---|---|---|
| verse | Noto Serif Devanagari | 25 / 1.62 | colour gold |
| verseLarge (chant screen) | same | 23 | |
| transliteration | EB Garamond italic | 14.5 / 1.5 | faint |
| meaning | EB Garamond | 21 / 1.38 | ink |
| title | EB Garamond | 36 / 1.12 (32 on compact) | |
| body | EB Garamond | 19 / 1.45 (16–18 small) | mute |
| eyebrow / topline | Inter | 10.5, tracking .18–.24em, uppercase | accent or faint |
| button | Inter SemiBold | 15, tracking .03em | |
| number-hero | EB Garamond | 130 (milestone), 88 / 68 (points) | gold |
| ref ("GITA 2.47") | Inter | 10.5, tracking .2em | faint |

Respect system font scale up to 1.3. Verses may wrap to 3 lines.

## 3. Space, shape, elevation

- Screen padding: 26 sides, 54 top, 30 bottom. Spacing steps: 6, 12, 14, 18, 22, 30, 34.
- Radius: 18 (rows, options), 28 (buttons, pills), 42 (phone frame in the board only), 22 (cards).
- Button: height 56, full width. Gradient btnA to btnB, 1 px inner top highlight (white 50%), 3 px edge colour below, soft glow shadow. Pressed: translate down 2 px, edge becomes 1 px.
- Option row: height 60, radius 18, 1 px line. Selected: marigold border + marigold 9% fill.
- Tab bar: 3 items (Today, Yatra, You), 22 px icon, label 10 px uppercase. Active = marigold with glow.
- Background mandala: `assets/mandala.svg`, 560 px, 6% opacity (9% light), centred at 44% height.

## 4. Motion

Curves: `spring = Cubic(.22, 1.2, .36, 1)`, `easeOut` for fades, linear for ambient loops.

| Motion | Duration | Curve |
|---|---|---|
| button press | 90 ms | easeOut, 2 px |
| option select | 150 ms | easeOut |
| verse snap | 380 ms | spring, 6 px overshoot, snaps past 25% drag or fast fling |
| listen wash in / out | 350 / 250 ms | easeOut |
| keep lotus bloom | 900 ms | spring, scale .2 to 1.08 to 1, then fade |
| Om / aura pulse | 4.8 s loop | easeInOut, scale 1 to 1.07 |
| flame flicker | 2.6 s loop | easeInOut, ±1.5 degree |
| active step ring breathe | 3.6 s loop | easeInOut |
| lamp ignite | 600 ms | easeOut |
| streak lamps | 140 ms apart | easeOut |
| points count-up | 1.2 s | easeOut, once per day |
| peacock fan opens | 1.1 s | spring, 9 feathers at ±52, ±39, ±26, ±13, 0 degrees, then fade out |
| petals | 7 s fall, 10 per screen | linear, rose and marigold |
| milestone lotus | 1.4 s | spring |
| chapter lotus | 1.4 s | petal by petal |

Honour "reduce motion": drop loops and petals, keep fades.

## 5. Assets (all exported)

Folder: `docs/design-board-v3/assets/`

| File | Use |
|---|---|
| `icons/diya.svg` | line diya, Today tab |
| `icons/lotus.svg` | You tab, Yatra "now" node |
| `icons/conch.svg` | Hear step, milestone |
| `icons/chakra.svg` | spare (chapter marks) |
| `icons/flute.svg` | Speak step, chant ring |
| `icons/feather.svg` | peacock-feather stone, Mann Darpan reply |
| `icons/peacock.svg` | celebration accents |
| `icons/kadamba.svg` | Yatra decoration |
| `icons/butter-pot.svg` | spare (Sankalp sealed) |
| `icons/path-stone.svg` | Yatra stone, Walk step, Yatra tab |
| `icons/check.svg` | done stone |
| `icons/mic.svg` | Mann Darpan orb |
| `emblem.svg` | welcome screen (feather over bansuri, aura, garland, kadamba) |
| `diya-solid.svg` | hero lamp |
| `lotus-filled.svg` | milestone, chapter complete |
| `feather-art.svg` | feather fan (use 9, rotate around the base) |
| `mandala.svg` | background |

Icons are drawn on a 64 grid, 2.1 px stroke, round caps, colour `#FFC247`. Recolour at runtime (flutter_svg `ColorFilter`). Glow = blurred copy at 55% opacity behind the icon. `emblem.svg` uses `<symbol>` and `<use>`: if `flutter_svg` does not render it, flatten it once in Inkscape or SVGO (`--enable=inlineUse`).
Rasterise `emblem.svg` and `feather-art.svg` to PNG @3x as a fallback.

## 6. Screens and the one primary action each

| Screen | Primary action | Notes |
|---|---|---|
| Welcome | "Listen" | emblem, aura breathes |
| The ritual | "Continue" | three icons draw in |
| Reminder | "Light the first lamp" | one dial, default 6:30 |
| Today | "Begin today's ritual" (then "Continue the ritual") | rail: Hear, Walk, Speak |
| Today, after a missed day | "Light it again" | dim lamp, "You came back." |
| Verse scroll | swipe up | hold = listen, double-tap = keep, no buttons |
| End of feed | "Walk the next step" | secondary "Rest for now" |
| Walk: Chant along (default) | hold the ring | |
| Walk: Where it meets you | "This one" | |
| Walk: Finish the verse | speak | skip after 8 s |
| Lesson complete | "Continue" | lamp, feather fan, petals, points |
| Milestone (7 / 30 / 100 / 365) | "Share this light" | secondary "Continue" |
| Yatra path | tap the glowing lotus | |
| Chapter complete | "Continue the Yatra" | |
| Mann Darpan: ask | tap the orb | secondary "Type instead" |
| Mann Darpan: listening | "Done" | |
| Mann Darpan: answer | "Seal as my Sankalp" | secondary "Not today" |
| You | none (list) | 5 settings below |

You settings (max 5): Reminder, Language (Hindi / English / Hinglish), Sound and haptics (one toggle), Appearance (Auto / Night), Privacy and data.

## 7. The three scripture interactions

1. **Chant along (default Walk step).** Press and hold the ring. Chant audio plays, each line brightens in time, the ring fills clockwise. Release pauses. Ring full = step walked. No score, cannot fail. One haptic tick per line.
2. **Where it meets you (inside Mann Darpan replies).** Three plain text lines of life under the verse, no chips. Pick one and show a short reply in the voice of the verse. No wrong line.
3. **Finish the verse (chapter-end Checkpoint).** Hear line one, speak line two. Words light as recognised; sound-alike counts. Skip appears after 8 s with no penalty.

Voice copy rule: the verse speaks, the app never says "I am God". Always attribute ("Krishna told Arjuna..."). Second person, under 12 words a sentence, no exclamation marks.

## 8. Light mode rule

Appearance = Auto: Today uses Ivory Dawn from local sunrise-ish 05:00 to 10:00, otherwise Night. Verse scroll, Walk, Mann Darpan, rewards stay dark always. "Night" in settings forces dark everywhere.

## 9. Sound and haptic map

Sounds: soft, Indian instruments, under 1.2 s, cues at about -12 LUFS, beds at -18. One toggle turns sound and haptics off together. Haptics use platform patterns only.

| Moment | Sound | Haptic |
|---|---|---|
| Open app | flute breath, one note | none |
| Primary button | quiet wood tap | light impact |
| Pick an option | none | selection tick |
| Swipe to next verse | low wood "tok" | selection tick |
| Hold to listen | chant plays | one soft tick |
| Keep a verse | singing-bowl tink | light impact, then soft |
| Chant along, each line | tanpura under chant | one tick per line |
| End of feed | low bell | soft |
| Mann Darpan start | tanpura fades in (-30 dB) | light impact |
| Mann Darpan listening | none | none |
| Mann Darpan reply | bell | soft |
| Step walked | bell, warm pad | success |
| Milestone | conch, once | success, then soft |
| Chapter complete | bowl and tanpura swell | success |
| Return after missed day | soft bell | none |
| Wrong or skipped | none | none |

Audio files still to be made: flute breath, wood tap, wood tok, singing bowl, bell, low bell, warm pad, conch, tanpura loop, chant per verse (108+).

## 10. Streak rules (design side)

Seven lamps per week. A missed day dims that lamp, never red, never "lost". One missed day a week is forgiven silently. Moksh points only go up. Return copy: "You came back. The lamp was still warm."

## 11. Open items for the builder

- Chant audio and 108+ real shlokas are content tasks, not design.
- Verify the Devanagari verse never clips with the 1.3x font scale.
- The board's numbers are the spec; if a value in code differs, the board wins.
