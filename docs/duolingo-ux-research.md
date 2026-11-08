# Duolingo UX Research → DharmaScroll Redesign

Source: [Duolingo app case study (Medium)](https://medium.com/design-bootcamp/ux-research-duolingo-app-case-study-54230f0aa4f7)
Plus: Duolingo handbook, blog posts on Friend Streak, Path delight, reactivation flow, Octalysis framework.

## Core Duolingo principles (extracted)

1. **Retention > acquisition.** Optimize for "will they come back tomorrow?"
2. **Habit loop (Hook model):** Trigger (push, guilt) → Action (near-zero friction, 3–5 min) → Variable reward (XP, chests, combos) → Investment (streak grows, loss aversion compounds).
3. **Make failure safe.** Wrong answers → gentle animations + encouraging feedback, never red error screens.
4. **Progress must be visible & continuous.** Layered: XP bars, streaks, leagues, crowns, badges. Something always advancing, even on bad days.
5. **Micro-animations for immediate feedback.** Correct answers, progress, rewards.
6. **"Less is more" / intuitive.** No explanations needed; if a screen needs instructions it's wrong.
7. **Chunked sessions.** 3–5 min lowers activation energy to near zero.
8. **Identity-based goals.** "Casual / Regular / Serious / Intense" — picking a learner type, not minutes.
9. **Character = relationship vector.** Duo enables emotional stakes (guilt-trip notifications, celebrations) an abstract UI cannot.
10. **Color as energy system.** Saturated, semantic colors per state (green=success, red=hearts/urgency, orange=streak, yellow=XP, purple=premium).
11. **Path design.** Linear progression with units, clear next step, pulsating active node.
12. **Celebrate at multiple levels.** Lesson → node → section → league promotion, each with motion.
13. **Variable rewards.** Surprise chests, combo bonuses, ramp-up challenges with time limits.
14. **Loss aversion.** Streak at risk → notifications; fear of losing earned progress.
15. **Full-screen immersive flows.** Onboarding/reactivation as full-screen, not overlays.
16. **Delight via motion, characters, absurd moments.** "Wholesome but unhinged."

## Mapping to DharmaScroll

| Duolingo concept | DharmaScroll equivalent | Current state | Gap |
|---|---|---|---|
| Daily lesson (3–5 min) | Feed scroll (shlokas) | Feed exists | No session length cap / "done for today" is good; needs clearer daily goal |
| XP | Moksh Points | Wallet exists | No visible MP bar on feed; no variable rewards |
| Streak | Sankalp streak | Check-in exists | No streak-at-risk, no loss-aversion nudges |
| Path / units | Gita Yatra | Yatra screen | No pulsating active node, no unit grouping |
| Hearts (lives) | — | none | Could add "tapas" (energy) for retry-heavy features |
| League / social | Sangha | Screen exists | No leaderboard, no promotion animation |
| Character (Duo) | — | none | Missing mascot (diya/guru figure) for emotional connection |
| Identity goal selection | Onboarding intent | Basic | Could use identity labels |
| Safe failure | Checkpoint "wrong costs nothing" | Already good | Keep; add gentle animation |
| Celebrate milestones | Daily reward sheet | Exists | Needs confetti/Lottie, multi-level |
| Variable rewards | — | none | Add surprise MP chests |
| Full-screen onboarding | Onboarding flow | Exists | Make more immersive |

## Redesign principles for DharmaScroll

1. **One clear next action on home** — pulsating active node (today's shloka), no ambiguity.
2. **MP + streak always visible** in app bar / feed header.
3. **Safe failure** — wrong checkpoint = gentle shake + encouraging copy, no red.
4. **Micro-animations everywhere** — correct, reward, level-up, streak (Lottie).
5. **Chunked daily session** — cap at ~5 min, clear "done for today" celebration.
6. **Celebrate at multiple levels** — checkpoint ✓ → daily complete 🎉 → streak milestone 🔥.
7. **Mascot** — a diya/flame character for emotional stakes & notifications.
8. **Identity-based onboarding** — "Casual seeker / Regular sadhak / Serious yogi / Intense tapasvi".
9. **Variable rewards** — surprise MP chests after every Nth card.
10. **Loss aversion** — streak-at-risk push notification with mascot.
11. **Color as energy** — sindoor = success/CTA, gold = MP/reward, red = crisis (Mann Darpan), green = correct.
12. **Intuitive, no instructions** — remove coach-mark banner; use spotlight tour once.

## Implementation batches (map to existing issues)

- #4 (animations) → add celebration Lotties (reward, checkpoint, streak)
- #5 (loading/onboarding) → identity-based goal picker + skeleton loading
- #6 (sheets/lists) → gesture-driven sheets, slidable saved items
- #7 (export) → share card viral loop
- #8 (audio) → Mann Darpan voice notes
- #9 (showcaseview) → spotlight tour (replace banner)
- #10 (charts) → Yatra path visualization
- #11 (Lottie) → mascot + micro-animations

## Open questions
- Mascot character: diya flame vs. a sage figure? (needs designer decision)
- Daily session length target: 5 min? 7 cards? (data needed)
- Add "energy/hearts" mechanic or keep punishment-free? (product decision)
