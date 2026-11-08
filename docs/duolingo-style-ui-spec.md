# DharmaScroll — Duolingo-Tier UI Spec

Companion to `docs/duolingo-ux-research.md` and issue #12. Actionable design spec: concrete Flutter widgets + file paths. No app code changed by this doc.

## 1. Information architecture / screen map

Routes (go_router, `lib/core/router/app_router.dart`):
- `/onboarding` (full-screen, first run only)
- `/` shell (`lib/presentation/shell/app_shell.dart`) with bottom nav `ShlokaNavBar`:
  - Shloka (home path) → `lib/presentation/feed/feed_screen.dart` becomes the **Path home**
  - Yatra → `lib/presentation/yatra/yatra_screen.dart` (unit map)
  - Mann (mic) → `lib/presentation/mann/mann_screen.dart`
  - Sangha → `lib/presentation/sangha/sangha_screen.dart`
  - Profile → `lib/presentation/profile/profile_screen.dart`
- Lesson session: pushed full-screen `/lesson/:id` over home
- Reward: modal sheet / full-screen celebration route
- Crisis: `/mann/crisis` (`crisis_screen.dart`)

Home tab is the single source of "what do I do next".

## 2. Home "Path" screen

File: `lib/presentation/feed/feed_screen.dart` (repurpose) + new `lib/presentation/path/path_screen.dart`.

Layout (top → bottom):
- Header row: streak badge (left), MP pill (`lib/core/widgets/mp_pill.dart`, center), settings (right).
- Daily goal progress bar (linear, sindoor fill).
- Vertical scrollable `ListView` of units; each unit = header + zig-zag node column.
- Bottom nav.

Node states (`lib/presentation/path/path_node.dart` widget):
- `locked`: greyed, lock icon, no tap.
- `active`: pulsating (scale 1.0→1.08, 900ms, repeat) sindoor node, halo ring.
- `completed`: gold check, subtle.
- Units grouped with header banner; completed units collapse.

Pulsating uses `flutter_animate` `Animate.onPlay` + `shimmer`? No — `flutter_animate` repeat.

## 3. Lesson flow

New: `lib/presentation/lesson/lesson_screen.dart`.
- Full-screen, no bottom nav.
- Top: progress bar (X of N) + close (X) → confirm exit sheet.
- Body: card stack via `smooth_page_indicator`? Use `PageView` + `smooth_page_indicator` dots.
- Card types reuse `lib/presentation/feed/widgets/shloka_card.dart`, `checkpoint_card.dart`.
- 3–5 min target = 7 cards + 1 checkpoint every 3.
- Safe failure: checkpoint wrong → gentle shake (`flutter_animate` shake) + encouraging copy, no red screen.
- Completion → reward sheet.

## 4. Reward / celebration

Files: `lib/presentation/mp/daily_reward_sheet.dart` (extend), new `lib/presentation/reward/celebration.dart`.
Levels:
1. Checkpoint ✓ — small confetti burst (`confetti`), haptic.
2. Daily complete 🎉 — full-screen Lottie + MP count-up.
3. Streak milestone 🔥 — flame Lottie, streak badge pulse.
4. Surprise chest — variable reward modal (every Nth card), `modal_bottom_sheet`.

## 5. Onboarding

File: `lib/presentation/onboarding/onboarding_flow.dart` (rewrite immersive).
- Full-screen pages (PageView + `smooth_page_indicator`).
- Step 1: welcome + mascot.
- Step 2: identity goal picker: Casual seeker / Regular sadhak / Serious yogi / Intense tapasvi (chips).
- Step 3: streak setup (start streak today toggle).
- Step 4: spotlight tour via `showcaseview` (replaces coach_marks banner).
Remove `lib/presentation/feed/widgets/coach_marks.dart` banner.

## 6. Color system

Keep AppColors tokens but map semantically for Duolingo saturation:
- sindoor `primary` = CTA + success (saturated)
- gold = MP/reward
- red `danger` = crisis (Mann Darpan) only
- green `success` = correct answer
- kesar `accentKesar` = streak flame
- surfaces parchment.

Ratri (dark) mirrors.

## 7. Component specs

- `PathNode` widget: 64px circle, states above, halo for active.
- `ProgressRing` (circular) for daily goal; reuse Material `CircularProgressIndicator` styled, or custom.
- `StreakBadge`: flame icon + count, pulse on increment.
- `MpPill`: existing, add count-up animation.
- `MascotPlaceholder`: Lottie asset slot `assets/lottie/mascot_idle.json` (placeholder).
- Bottom nav: existing `ShlokaNavBar`, add selected-state scale.

## 8. Animation specs

- Entrance: 200ms fade+slide up, `flutter_animate`.
- Correct: scale bounce 1.0→1.15→1.0 300ms + green flash.
- Reward: confetti 2s + count-up.
- Level-up: Lottie full-screen.
- Streak-at-risk: flame flicker Lottie + red tint.

## 9. Library mapping

- flutter_animate: node pulse, entrances, shake, count-up.
- lottie: mascot, celebration, streak flame.
- confetti: reward bursts.
- showcaseview: onboarding tour.
- modal_bottom_sheet: chests, exit confirm.
- fl_chart: Yatra path + MP history.
- smooth_page_indicator: lesson/onboarding dots.
- shimmer: skeleton loading (issue #5).

## 10. Phased plan

Phase 1 — Home path (issue to create): repurpose feed → path, PathNode, unit grouping. Issues: #12, #10.
Phase 2 — Lesson flow: lesson screen, PageView, checkpoints. Issues: #4, #6.
Phase 3 — Rewards: celebration, confetti, chests. Issues: #4, #11.
Phase 4 — Onboarding: identity goals, streak setup, showcaseview. Issues: #5, #9.
Phase 5 — Mascot + streak notifications: Lottie mascot, push. Issues: #11, #8 (audio optional).
Phase 6 — Polish: shimmer loading, fl_chart, accessibility pass.

## Open decisions (carry from research)
- Mascot: diya flame vs sage.
- Session length: 5 min / 7 cards.
- Energy/hearts mechanic.
