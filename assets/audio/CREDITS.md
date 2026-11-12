# Audio credits

Every sound here is synthesised from scratch by `tools/sound_gen/generate.py`
(sine, additive and filtered-noise synthesis, fixed random seed). No samples,
no recordings, no third-party material. The files are original works of this
project; there is no external licence to attribute.

| File | What it is | Used for |
|---|---|---|
| tap.m4a | soft wood tap | primary button |
| tok.m4a | low wood tok | verse snap |
| bowl.m4a | singing-bowl tink | keep a verse |
| bell.m4a | temple bell | lesson complete |
| bell_low.m4a | low temple bell | end of feed |
| shimmer.m4a | lamp-light shimmer | lamp ignite, lesson complete |
| chime.m4a | rising pentatonic chime | chant ring full |
| conch.m4a | conch-like swell | milestone (not wired yet) |
| swipe.m4a | soft page swipe | onboarding page turn |
| drone.wav | tanpura loop, 8 s, seamless | hold to listen, Chant along |

Regenerate: `python3 tools/sound_gen/generate.py` (numpy, ffmpeg).
Measure: `python3 tools/sound_gen/analyze.py`.
