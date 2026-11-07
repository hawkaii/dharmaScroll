# DharmaScroll — Week 1 Execution Plan

**Goal:** ship a real, installable Flutter MVP in 7 days: the Shloka feed, Moksh Points, Gita Yatra (Chapters 1–3), Daily Sankalp, onboarding, and Mann Darpan working on a seed set of ~108 verses with local tag-matching.

**Source of truth:** `DharmaScroll_Product_Blueprint.pdf` (v1.0, November 2026) and `dharmascroll-site.html`.

**Repo today:** a Flutter starter template. ~110 lines of app code, zero dependencies, CI that builds an APK on every push to `main`. There is no product code yet.

---

## 1. Scope for the week

### Build this week (MVP slice)

| # | Feature | Definition of done |
|---|---|---|
| 1 | Design system | Blueprint palette + fonts; light and Ratri themes |
| 2 | Shloka feed | Full-screen vertical feed, one shloka per card, offline |
| 3 | Expand sheet | Shabdarth / Katha / Jeevan tabs |
| 4 | Moksh Points | Append-only ledger, caps, streak, Vishram, wallet |
| 5 | Checkpoints | Quiz/reflection card every 7 shlokas |
| 6 | Gita Yatra | 18-chapter path UI, Ch 1–3 playable with quiz |
| 7 | Daily Sankalp | Create + evening check-in (done / partly / not today) |
| 8 | Mann Darpan v0 | Text/voice input, local tag retrieval, lesson + 3 actions |
| 9 | Onboarding | 6 screens, guest-first, deferred OTP |
| 10 | Share card | 9:16 PNG with watermark + share sheet |
| 11 | Profile | Stats, badges, saved shlokas, journal, settings |
| 12 | Release build | Signed APK, green CI, v0.1.0 tag |

### Explicitly deferred (do not attempt this week)

| Item | Why it waits | Target |
|---|---|---|
| All 700 verses scholar-tagged | Weeks of human review; it is the moat | Weeks 2–8 |
| Chant/meaning audio (1,400 files) | Studio recording | Weeks 2–6 |
| Real Sarvam STT + LLM + TTS | Python service, pgvector, ops | Week 2 |
| Sangha leagues / Sakha / Parivar | V1.1 in blueprint | Weeks 5–6 |
| Pro paywall / RevenueCat | Needs store accounts + products | Weeks 9–12 |
| 60 illustrations, widgets, focus lock | Art + native work | Later |
| Play Store / App Store launch | Review cycles, ASO | Weeks 13–16 |

### Hard rule

**Content is the bottleneck, not code.** If the 108 seed verses are not ready on Day 1, the week slips. One person must own verse text + tagging.

---

## 2. Stack decisions (lock before Day 0)

| Layer | Choice | Reason |
|---|---|---|
| Mobile | Flutter 3.x + Dart | Repo is already Flutter; blueprint allows it |
| State | Riverpod | Testable, no BuildContext coupling |
| Routing | go_router | Declarative, deep links for share cards |
| Local DB | Drift (SQLite) | Typed queries for MP ledger + verse state |
| Audio | just_audio | Stream + cache chant audio |
| Recorder | record | Mann Darpan mic input |
| Notifications | flutter_local_notifications | Morning + evening reminders |
| Share | share_plus | Share card + deep link |
| Backend | Supabase (week 2) | Auth, Postgres, RLS, storage |
| AI | Sarvam + LLM (week 2) | STT/TTS/lesson generation |
| Analytics | PostHog + Sentry (week 2) | Funnels, crashes |

**Do not switch to React Native.** The blueprint names RN + Expo as one option and Flutter as an equally valid one. Switching now throws away the CI and shell already in the repo.

---

## 3. Branch and commit workflow

```
main                     protected; CI green; APK builds
└── feature/week-1-mvp   all week-1 work
    ├── feat/design-system
    ├── feat/shloka-feed
    ├── feat/mp-engine
    ├── feat/yatra-sankalp
    ├── feat/mann-darpan
    └── feat/onboarding-share
```

- One feature branch per day, squash-merge into `feature/week-1-mvp`.
- Commit style follows the repo: `feat:`, `fix:`, `docs:`, `ci:`, `chore:`.
- `flutter analyze` and `flutter test` must pass before every merge.
- Open a PR into `main` only on Day 7 after the release build is verified.

---

## 4. Day-by-day execution

### Day 0 — Decisions and scaffolding (3–4 hours)

**Tasks**

- [ ] Confirm Flutter, seed verse set owner, and local-only backend for week 1.
- [ ] Create branch `feature/week-1-mvp`.
- [ ] Add dependencies to `pubspec.yaml`:
  `flutter_riverpod`, `go_router`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `just_audio`, `record`, `share_plus`, `flutter_local_notifications`, `google_fonts`, `intl`, `uuid`.
- [ ] Create folder structure:

```
lib/
  main.dart
  app.dart
  core/
    router/app_router.dart
    theme/app_colors.dart
    theme/app_theme.dart
    constants/app_constants.dart
  data/
    models/verse.dart
    models/mp_event.dart
    models/sankalp.dart
    models/lesson.dart
    repositories/verse_repository.dart
    repositories/progress_repository.dart
    services/local_db.dart
  presentation/
    shell/app_shell.dart
    screens/onboarding/
    screens/feed/feed_screen.dart
    screens/feed/widgets/shloka_card.dart
    screens/feed/widgets/expand_sheet.dart
    screens/feed/widgets/checkpoint_card.dart
    screens/yatra/yatra_screen.dart
    screens/mann/mann_darpan_screen.dart
    screens/sangha/sangha_screen.dart
    screens/profile/profile_screen.dart
    widgets/
assets/
  verses/gita_seed.json
  audio/
  art/
```

- [ ] Define the `Verse` JSON schema exactly per blueprint §06:

```json
{
  "id": "3.21",
  "chapter": 3,
  "number": 21,
  "yogaName": "Karma Yoga",
  "sanskrit": "...",
  "iast": "...",
  "meaningHi": "...",
  "meaningEn": "...",
  "wordMeanings": [{"word": "...", "root": "...", "meaning": "..."}],
  "speaker": "Krishna",
  "listener": "Arjuna",
  "context": "...",
  "lessonHi": "...",
  "lessonEn": "...",
  "emotionTags": ["anger", "pride"],
  "situationTags": ["work", "leadership"],
  "audioChantUrl": "",
  "illustrationId": "",
  "difficulty": 2,
  "adviceSafe": true
}
```

- [ ] Wire a 5-tab shell with a centre mic button: Shloka / Yatra / Mann / Sangha / Profile.

**Acceptance:** app boots into the shell, `flutter analyze` clean, `flutter test` green.

---

### Day 1 — Design system and data layer

**Tasks**

- [ ] Split colours into `core/theme/app_colors.dart`:

| Token | Hex | Use |
|---|---|---|
| Patra | `#F5ECD9` | base parchment |
| Bhoj | `#EAD8B3` | aged edge |
| Card | `#FBF6EA` | surfaces |
| Kesar | `#C2601C` | primary action |
| Sindoor | `#6E1F1A` | headings, Sanskrit |
| Swarna | `#B08A2E` | rewards, MP |
| Masi | `#2A1C11` | body text |
| Ratri | `#1F0F0A` | night mode |

- [ ] Load fonts with `google_fonts`: Tiro Devanagari Sanskrit (shlokas), EB Garamond (translations), Inter (UI), Noto Sans Devanagari (Hindi UI).
- [ ] Build `Verse` model + `VerseRepository` that loads `assets/verses/gita_seed.json`.
- [ ] Add seed set of ~108 famous verses: 2.47, 2.48, 2.50, 2.55, 3.21, 6.5, 12.x, 18.x etc. Each fully tagged.
- [ ] Register asset in `pubspec.yaml`.

**Acceptance:** a debug screen lists all seeded verses with correct Devanagari rendering, light and Ratri themes both readable.

---

### Day 2 — Shloka feed and expand sheet (core screen)

**Tasks**

- [ ] `FeedScreen` with vertical `PageView`, one card per shloka.
- [ ] `ShlokaCard` layers:
  - quiet header: `ADHYAY {n} · {yoga} · SHLOKA {n}`
  - Devanagari (largest element)
  - IAST transliteration
  - one-line meaning (Hindi / English / both)
  - right rail: chant, save, share, MP indicator
  - "Tap to go deeper" cue
- [ ] `ExpandSheet` with three tabs:
  - **Shabdarth** — word-by-word + anvaya
  - **Katha** — speaker, listener, scene
  - **Jeevan** — 60–90 word modern lesson
- [ ] Double-tap to save with lotus-burst animation; long-press to share.
- [ ] 280 ms transition, subtle background parallax.
- [ ] Feed modes: For You / Kram (sequential, resumes) / Topics.

**Acceptance:** 60 fps swipe through the seed set offline; expand sheet opens and closes without layout overflow on a small phone.

---

### Day 3 — Moksh Points engine, checkpoints, daily goal

**Tasks**

- [ ] Drift tables: `mp_ledger` (append-only) and `user_stats` (cache).
- [ ] Ledger columns: `id, user_id, ts, event_type, delta, ref_type, ref_id, day_bucket, idempotency_key`.
- [ ] Implement earning rules:

| Action | MP | Cap/day |
|---|---|---|
| Read shloka (visible ≥ 6 s or audio played) | +2 | 20 |
| Open expand sheet (Katha or Jeevan) | +3 | 10 |
| Checkpoint correct | +5 | no cap |
| Yatra lesson complete | +20 | no cap |
| Perfect quiz | +10 bonus | — |
| Chapter complete | +100 bonus | — |
| Mann Darpan entry (≥ 15 s) | +15 | 2 |
| Sankalp done | +25 | 1 |
| Sankalp partly | +10 | 1 |
| Reflection note | +8 | 3 |
| Daily goal met | +15 | 1 |

- [ ] Implement protective rules: no deduction for mood; honest "not today" = 0; points never below level floor; speed-scroll (5 cards < 2 s) pauses feed points for 10 min.
- [ ] Checkpoint card every 7 cards: quiz + reflection note.
- [ ] Streak + Vishram: 2 free rest days/month, +1 per 7-day streak, max 5 banked.
- [ ] "Nitya Path complete" reward sheet with itemised MP.
- [ ] MP wallet/ledger screen with rules link.

**Acceptance:** unit tests prove caps, idempotency, and that a sad mood never loses points.

---

### Day 4 — Gita Yatra and Daily Sankalp

**Tasks**

- [ ] `YatraScreen`: 18 chapters as a winding path; Ch 1–3 unlocked, rest locked.
- [ ] Lesson player: 5 shlokas + quiz + chapter summary.
- [ ] `Sankalp` model and create flow from a verse's Jeevan line.
- [ ] Evening check-in: done / partly / not today (honest "not today" = 0 MP).
- [ ] Local notifications: morning shloka at user time, evening check-in; max 2/day; never 10 pm–7 am.

**Acceptance:** complete Ch 1 Lesson 1 end-to-end; create a Sankalp; check in; notifications fire in a device test.

---

### Day 5 — Mann Darpan v0

**Tasks**

- [ ] Input screen: hold-to-talk mic + text fallback; max 2 min; privacy line ("audio deleted after transcription").
- [ ] Local retrieval v0:
  1. Normalise text, extract emotion + situation keywords.
  2. Score seed verses: `0.5 × tag overlap + 0.4 × keyword similarity + 0.1 × freshness`.
  3. Return top 3.
- [ ] Result screen: primary shloka + chant, 2-sentence "why this shloka", Jeevan Path (3 actions), Sankalp button, "Show another shloka".
- [ ] Crisis gate: keywords for self-harm/abuse → crisis screen with Tele-MANAS 14416 and 112; no lesson, no points.
- [ ] Persist entry to private journal.

**Acceptance:** 10 test inputs return a relevant verse; crisis input always bypasses the normal path.

**Note:** this is deliberately local retrieval, mirroring the blueprint's "retrieval before generation". The real Sarvam/LLM pipeline is week 2.

---

### Day 6 — Onboarding, auth, share cards

**Tasks**

- [ ] Onboarding: Splash → Language → Intent → Daily goal/reminder → guest feed → deferred OTP after 5 cards or first save.
- [ ] Supabase schema (optional this week): `users`, `user_verse_state`, `sankalps`, `mann_entries`; RLS on.
- [ ] Share card: `RepaintBoundary` → 9:16 PNG, parchment/Madhubani/Ratri variants, watermark + deep link, share via `share_plus`.
- [ ] Coach marks on the first real card (4 gestures).

**Acceptance:** install → first shloka in under 30 s; save triggers sign-up; share card renders correctly on Instagram Story dimensions.

---

### Day 7 — Polish, test, build, release

**Tasks**

- [ ] Profile screen: stats, badges, saved shlokas, journal, mood trend, settings/language.
- [ ] Accessibility: text size to 200%, Sanskrit never below 20 pt, contrast ≥ 7:1.
- [ ] Tests: MP rules, feed pagination, checkpoint insert, Mann Darpan retrieval, crisis gate.
- [ ] `flutter analyze` and `flutter test` clean.
- [ ] Release keystore + `flutter build appbundle` (Play) and `flutter build apk --split-per-abi`.
- [ ] Tag `v0.1.0`, push, verify CI artifact.
- [ ] Open PR `feature/week-1-mvp` → `main`.

**Acceptance:** signed release APK installs on a physical Android device; CI green; PR merged.

---

## 5. Definition of done (week 1)

- [ ] App installs from a release APK on a real device.
- [ ] Onboarding → first shloka under 30 seconds.
- [ ] Feed swipes smoothly through 108 verses offline.
- [ ] Expand sheet, save, share all work.
- [ ] MP ledger is auditable and caps are enforced.
- [ ] Checkpoints appear every 7 cards.
- [ ] Yatra Ch 1–3 playable with quiz and completion.
- [ ] Sankalp create + evening check-in works.
- [ ] Mann Darpan returns a relevant verse for 10 test inputs.
- [ ] Crisis path shows Tele-MANAS and awards no points.
- [ ] `flutter analyze` and `flutter test` pass.
- [ ] `v0.1.0` tag exists with a downloadable APK artifact.

---

## 6. Risks and mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Seed content not ready on Day 1 | High | Start with 27 verses (Ch 2, 3, 6, 12) and expand; content owner assigned Day 0 |
| Scope creep into AI/backend | High | Local retrieval only this week; AI is a separate week-2 branch |
| Devanagari rendering issues | Medium | Test on Android early; bundle a font instead of relying on google_fonts if needed |
| MP rules feel punitive | Medium | No mood deductions; honest check-in = 0; unit tests encode the rule |
| Android build/CI breaks | Medium | Keep `analyze` + `test` green daily; build APK on Day 2 and Day 7 |
| Time lost on auth/backend | Medium | Guest mode first; Supabase is optional until Day 6 |

---

## 7. Week 2 preview (out of scope for this plan)

- Python FastAPI Mann Darpan service: Sarvam Saaras STT → safety/tagging → pgvector retrieval → LLM lesson → verification → Bulbul TTS.
- Supabase production schema, RLS, server-authoritative MP validation.
- Content pipeline: scholar review, 700 verses, audio recording, artwork commissioning.
- PostHog funnels + Sentry.
- Sangha leagues and Sakha pairing.

---

*Prepared for the DharmaScroll team. This plan is a companion to `DharmaScroll_Product_Blueprint.pdf` and does not replace it.*
