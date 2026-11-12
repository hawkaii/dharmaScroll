# Audio credits

Every sound here is cut from a real recording of a real instrument. Each
source is released under **CC0 1.0** (public domain dedication,
<https://creativecommons.org/publicdomain/zero/1.0/>), so no attribution is
required; we credit the recordists anyway. Licences were checked on each
sound's Freesound page on 2026-11-13. The audio was taken from Freesound's
public HQ preview of each sound (no account needed).

`tools/sound_gen/build.py` downloads the sources, trims them, fades the
natural tail, applies a gentle high pass, sets the level, and encodes. The
only other change: the shimmer layers one bell recording at three pitches by
resampling it. Nothing is synthesised.

| File | Sound | Used for | Source | Recordist | Uploaded |
|---|---|---|---|---|---|
| tap.m4a | finger cymbal touch, 0.16 s | primary button | [Finger cymbals.WAV (439616)](https://freesound.org/people/Luc%20Henrion/sounds/439616/) | Luc Henrion | 2018-09-08 |
| tok.m4a | mokugyo (wooden temple block) | verse snap, share | [Mokugyo.wav (607215)](https://freesound.org/people/jonopodmore/sounds/607215/) | jonopodmore | 2021-11-06 |
| bowl.m4a | ghanta (brass hand bell), one ring | keep a verse, Sankalp, Ekant | [01drilbu (516574)](https://freesound.org/people/tenzin64/sounds/516574/) | tenzin64 | 2020-05-03 |
| bell.m4a | Indian temple bell, one strike | lesson complete, Ekant, Mann | [Indian Temple Bell.WAV (466652)](https://freesound.org/people/ganiket/sounds/466652/), Kothi, Himachal Pradesh | ganiket | 2019-04-18 |
| bell_low.m4a | large temple bell, low hum | end of feed | [Big Bell (760049)](https://freesound.org/people/ManDaKi/sounds/760049/) | ManDaKi | 2024-10-15 |
| shimmer.m4a | small bronze bell at three pitches | lamp ignite, lesson complete, onboarding | [Buddhist Bells.wav (189783)](https://freesound.org/people/dnewtonjr/sounds/189783/) | dnewtonjr | 2013-05-29 |
| chime.m4a | tingsha (small cymbal pair), ting-ting | chant ring full, verse finished, Sankalp, share | [Tingsha Cymbal (435074)](https://freesound.org/people/steffcaffrey/sounds/435074/) | steffcaffrey | 2018-07-20 |
| conch.m4a | shankha (conch), one full blow | milestone | [Snailhorn.wav (64830)](https://freesound.org/people/Ohrwurm/sounds/64830/) | Ohrwurm | 2008-12-19 |
| swipe.m4a | paper page turn | onboarding page turn | [Page Turn (755981)](https://freesound.org/people/SonicFXAudio/sounds/755981/) | SonicFXAudio | 2024-09-22 |
| drone.wav | tanpura, Sa = C#, 8.1 s seamless loop | hold to listen, Chant along, Mann, Ekant | [Tanpura 10 (153262)](https://freesound.org/people/sankalp/sounds/153262/), Tapan music center | sankalp | 2012-04-29 |

Rebuild: `python3 tools/sound_gen/build.py` (numpy, scipy, ffmpeg).
Measure: `python3 tools/sound_gen/analyze.py`.
