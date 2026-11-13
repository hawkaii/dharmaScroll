#!/usr/bin/env python3
"""Cut every dharmaScroll sound from real CC0 recordings (Freesound).

Usage:  python3 tools/sound_gen/build.py [out_dir]
Needs:  numpy, scipy, and ffmpeg on PATH.
Input:  the public HQ previews of the sources below, downloaded once into
        tools/sound_gen/.cache/ (no Freesound account needed).
Output: assets/audio/*.m4a (one-shots) and assets/audio/drone.wav (loop).

Each cue is a trim of one take (or a few layered takes), with a short fade
in, a cosine fade over the natural tail, a gentle high pass against rumble,
and a gain that puts it in the app's loudness band. Pitch shifts are done by
resampling the recording (the same bell, played as a bigger or smaller one).
No synthesised tones. Sources, authors and licences: assets/audio/CREDITS.md.

The drone is WAV on purpose: AAC/MP3 add encoder padding, which makes a loop
click at the seam. The loop point is searched for automatically (two matching
tanpura cycles) and closed with a crossfade, so the seam has no click.
"""
import subprocess
import sys
import tempfile
import urllib.request
import wave
from fractions import Fraction
from pathlib import Path

import numpy as np
from scipy.signal import butter, resample_poly, sosfiltfilt

SR = 44100          # one-shots
SR_DRONE = 22050    # drone loop: mono 16 bit, about 44 KB per second
HERE = Path(__file__).resolve().parent
CACHE = HERE / ".cache"
CDN = "https://cdn.freesound.org/previews/"

# Freesound id -> HQ preview path. All CC0 1.0 (checked on each sound page).
SOURCES = {
    439616: "439/439616_737466-hq.ogg",     # Luc Henrion, Finger cymbals
    607215: "607/607215_541139-hq.ogg",     # jonopodmore, Mokugyo
    516574: "516/516574_11350634-hq.ogg",   # tenzin64, 01drilbu (ghanta)
    466652: "466/466652_9226170-hq.ogg",    # ganiket, Indian Temple Bell
    760049: "760/760049_15096086-hq.ogg",   # ManDaKi, Big Bell
    189783: "189/189783_2800743-hq.ogg",    # dnewtonjr, Buddhist Bells
    435074: "435/435074_1844073-hq.ogg",    # steffcaffrey, Tingsha Cymbal
    64830: "64/64830_866470-hq.ogg",        # Ohrwurm, Snailhorn (shankha)
    755981: "755/755981_16361471-hq.ogg",   # SonicFXAudio, Page Turn
    153262: "153/153262_1859932-hq.ogg",    # sankalp, Tanpura 10 (Sa = C#)
}

# name: layers, fade-in s, fade-out s, high pass Hz, low pass Hz, RMS dBFS
# layer: (source id, start s, length s, semitones, delay s, gain dB).
# Start times are where the strike is; the cut snaps to the exact attack.
CUES = {
    # A light finger-cymbal touch, cut short: the quietest, most frequent cue.
    "tap": ([(439616, 0.18, 0.16, 0, 0, 0)], 0.004, 0.11, 300, 7000, -25),
    # Wooden temple block (mokugyo) with its cloth beater.
    "tok": ([(607215, 0.0, 0.34, 0, 0, 0)], 0.003, 0.18, 120, None, -22),
    # Keep a verse: one ghanta (hand bell) ring.
    "bowl": ([(516574, 0.18, 2.2, 0, 0, 0)], 0.004, 1.2, 150, None, -24.5),
    # Lesson complete, Ekant, Mann: an Indian temple bell, one strike.
    "bell": ([(466652, 0.51, 3.0, 0, 0, 0)], 0.004, 1.6, 150, None, -25),
    # End of feed: a large temple bell, long hum.
    "bell_low": ([(760049, 0.12, 3.6, 0, 0, 0)], 0.005, 1.8, 60, None, -24),
    # Lamp light: one small bronze bell, played as three bell sizes, rising.
    "shimmer": ([(189783, 19.08, 1.5, -9, 0.0, -2),
                 (189783, 19.08, 1.4, -4, 0.15, -3),
                 (189783, 19.08, 1.3, 0, 0.32, -5)],
                0.005, 0.9, 400, None, -27),
    # Ring full: the two tingsha cymbals struck together (ting-ting).
    "chime": ([(435074, 0.0, 2.0, 0, 0, 0)], 0.004, 1.1, 300, None, -23),
    # Milestone: one full shankha blow, swelling then fading.
    "conch": ([(64830, 1.1, 5.6, 0, 0, 0)], 0.01, 1.4, 120, None, -23),
    # Onboarding page turn: one soft paper turn.
    "swipe": ([(755981, 0.25, 0.3, 0, 0, 0)], 0.004, 0.12, 200, 8000, -31),
}
KBPS = {"swipe": 48, "tap": 48, "tok": 48}

DRONE_SRC, DRONE_WIN = 153262, (14.0, 46.0)  # steady, in tune, no talking
DRONE_LEN = (8.0, 10.5)                       # seconds; 10.5 s is 463 KB
DRONE_XFADE = 0.5
DRONE_RMS = -21


def fetch(sid):
    CACHE.mkdir(exist_ok=True)
    p = CACHE / f"{sid}.ogg"
    if not p.exists():
        req = urllib.request.Request(CDN + SOURCES[sid],
                                     headers={"User-Agent": "dharmaScroll"})
        with urllib.request.urlopen(req, timeout=60) as r:
            p.write_bytes(r.read())
    return p


def decode(path, sr=SR):
    raw = subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-i", str(path), "-ac", "1", "-ar",
         str(sr), "-f", "f32le", "-"], capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype="<f4").astype(np.float64)


def db(v):
    return 20 * np.log10(max(float(v), 1e-12))


def rms(x):
    return np.sqrt(np.mean(x ** 2))


def attack(x, t):
    """Index 4 ms before the attack nearest t: the first sample whose 1 ms
    envelope reaches a quarter of the strike's peak."""
    a, b = max(0, int((t - 0.08) * SR)), int((t + 0.3) * SR)
    env = np.convolve(np.abs(x[a:b]), np.ones(44) / 44, mode="same")
    i = int(np.argmax(env >= env.max() * 0.25))
    return max(0, a + i - int(0.004 * SR))


def shift(x, semitones):
    if semitones == 0:
        return x
    r = Fraction(2 ** (-semitones / 12)).limit_denominator(400)
    return resample_poly(x, r.numerator, r.denominator)


def fade(x, fin, fout):
    x = x.copy()
    n_in, n_out = int(fin * SR), int(fout * SR)
    x[:n_in] *= np.linspace(0, 1, n_in)
    x[-n_out:] *= 0.5 * (1 + np.cos(np.linspace(0, np.pi, n_out)))
    return x


def filt(x, hp, lp, sr=SR):
    if hp:
        x = sosfiltfilt(butter(2, hp, "highpass", fs=sr, output="sos"), x)
    if lp:
        x = sosfiltfilt(butter(4, lp, "lowpass", fs=sr, output="sos"), x)
    return x


def cue(layers, fin, fout, hp, lp, target):
    parts = []
    for sid, start, length, st, delay, gain in layers:
        src = decode(fetch(sid))
        i = attack(src, start)
        seg = src[i:i + int(length * SR)]
        seg = fade(shift(seg, st), fin, min(fout, length * 0.6))
        parts.append((int(delay * SR), seg * 10 ** (gain / 20)))
    n = max(d + len(s) for d, s in parts)
    y = np.zeros(n)
    for d, s in parts:
        y[d:d + len(s)] += s
    y = fade(filt(y, hp, lp), fin, fout)  # filters may ring at the edges
    y *= 10 ** ((target - db(rms(y))) / 20)
    if db(np.abs(y).max()) > -1:
        y *= 10 ** ((-1 - db(np.abs(y).max())) / 20)
        print(f"  peak-limited: rms now {db(rms(y)):.1f} dBFS")
    return y


def drone():
    """Two tanpura cycles, cut where the end sounds most like the start, and
    closed with an equal-power crossfade so the loop has no seam."""
    x = filt(decode(fetch(DRONE_SRC)), 35, None)
    a0, a1 = (int(t * SR) for t in DRONE_WIN)
    x = x[a0:a1]
    hop = SR // 50                                   # 20 ms feature frames
    nf = len(x) // hop
    sp = np.abs(np.fft.rfft(x[:nf * hop].reshape(nf, hop) * np.hanning(hop)))
    edges = np.geomspace(3, sp.shape[1] - 1, 41).astype(int)
    feat = np.log(np.stack([sp[:, a:b].sum(1) for a, b in zip(edges, edges[1:])],
                           1) + 1e-9)
    w = int(0.4 * 50)                                # compare 400 ms
    xf = int(DRONE_XFADE * 50)
    best = None
    for ln in range(int(DRONE_LEN[0] * 50), int(DRONE_LEN[1] * 50) + 1):
        for a in range(0, nf - ln - max(w, xf) - 1, 2):
            d = np.abs(feat[a:a + w] - feat[a + ln:a + ln + w]).mean()
            if best is None or d < best[0]:
                best = (d, a, ln)
    _, a, ln = best
    s, n, x_n = a * hop, ln * hop, xf * hop
    seg = x[s:s + n + x_n]
    out = seg[:n].copy()
    ramp = np.linspace(0, np.pi / 2, x_n)
    out[:x_n] = seg[n:n + x_n] * np.cos(ramp) + seg[:x_n] * np.sin(ramp)
    out = resample_poly(out, 1, 2)                   # 44.1 -> 22.05 kHz
    out -= out.mean()
    out *= 10 ** ((DRONE_RMS - db(rms(out))) / 20)
    print(f"  drone: source {DRONE_WIN[0] + s / SR:.2f}-"
          f"{DRONE_WIN[0] + (s + n) / SR:.2f} s, loop {n / SR:.2f} s, "
          f"match {best[0]:.3f}")
    return out


def write_wav(path, x, sr):
    pcm = np.round(np.clip(x, -1, 1) * 32767).astype("<i2")
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm.tobytes())


def to_m4a(wav, out, kbps):
    subprocess.run(
        ["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav), "-c:a", "aac",
         "-b:a", f"{kbps}k", "-movflags", "+faststart", str(out)], check=True)


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else \
        HERE.parents[1] / "assets" / "audio"
    out.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        for name, spec in CUES.items():
            print(name)
            wav = Path(tmp) / f"{name}.wav"
            write_wav(wav, cue(*spec), SR)
            to_m4a(wav, out / f"{name}.m4a", KBPS.get(name, 64))
    print("drone")
    write_wav(out / "drone.wav", drone(), SR_DRONE)
    print("wrote", out)


if __name__ == "__main__":
    main()
