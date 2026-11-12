#!/usr/bin/env python3
"""Synthesise every dharmaScroll sound from scratch (no samples, no licences).

Usage:  python3 tools/sound_gen/generate.py [out_dir]
Needs:  numpy, and ffmpeg on PATH (AAC encode of the one-shots).
Output: assets/audio/*.m4a (one-shots) and assets/audio/drone.wav (loop).

Everything is additive/sine/noise synthesis with a fixed seed, so the same
script gives the same files. Peaks are normalised per sound; the app plays
them well below full scale (see lib/core/feedback/sound_service.dart).

The drone is WAV on purpose: AAC/MP3 add encoder padding, which makes a
loop click at the seam. WAV is gapless on Android, iOS and the browser.
"""
import subprocess
import sys
import tempfile
import wave
from pathlib import Path

import numpy as np

SR = 44100          # one-shots
SR_DRONE = 22050    # drone loop: 8 s mono 16 bit = 352 KB
RNG = np.random.default_rng(108)


def t_(dur, sr=SR):
    return np.arange(int(dur * sr)) / sr


def env_exp(t, tau):
    return np.exp(-t / tau)


def fade(x, sr, fin=0.004, fout=0.03):
    """Linear in/out so no file starts or ends on a step."""
    n_in, n_out = int(fin * sr), int(fout * sr)
    x = x.copy()
    x[:n_in] *= np.linspace(0, 1, n_in)
    x[-n_out:] *= np.linspace(1, 0, n_out)
    return x


def norm(x, peak_db):
    return x / np.max(np.abs(x)) * 10 ** (peak_db / 20)


def lowpass(x, cutoff, sr=SR):
    """One-pole low pass; cutoff may be an array (sweep)."""
    c = np.broadcast_to(cutoff, x.shape)
    a = 1 - np.exp(-2 * np.pi * c / sr)
    y = np.empty_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc += a[i] * (x[i] - acc)
        y[i] = acc
    return y


# --- instruments ---------------------------------------------------------

def wood(f0, f1, dur, tau, brightness=0.25):
    """Wood block: pitch-dropped sine, one inharmonic mode, a soft click."""
    t = t_(dur)
    f = f1 + (f0 - f1) * np.exp(-t / 0.02)
    ph = 2 * np.pi * np.cumsum(f) / SR
    body = np.sin(ph) + 0.35 * np.sin(ph * 2.31) * env_exp(t, tau * 0.5)
    click = lowpass(RNG.standard_normal(len(t)), 2500) * env_exp(t, 0.004)
    return (body * env_exp(t, tau) + brightness * click) * 1.0


def bell(f0, dur, tau):
    """Temple bell: hum, prime, tierce, quint, nominal and upper partials,
    each slightly detuned in pairs so the tail beats slowly."""
    t = t_(dur)
    #        ratio  amp   decay-scale
    modes = [(0.5, 0.55, 1.4), (1.0, 1.0, 1.0), (1.19, 0.6, 0.8),
             (1.5, 0.35, 0.6), (2.0, 0.5, 0.55), (2.51, 0.25, 0.4),
             (3.0, 0.2, 0.3), (4.2, 0.1, 0.2)]
    y = np.zeros_like(t)
    for r, a, d in modes:
        for det in (0.0, 0.0018):
            y += 0.5 * a * np.sin(2 * np.pi * f0 * r * (1 + det) * t) \
                * env_exp(t, tau * d)
    atk = np.minimum(t / 0.003, 1)
    return y * atk


def bowl(f0, dur, tau):
    """Singing bowl tink: three bowl modes, slow beating, soft attack."""
    t = t_(dur)
    y = np.zeros_like(t)
    for r, a, d in [(1.0, 1.0, 1.0), (2.71, 0.45, 0.6), (5.15, 0.15, 0.3)]:
        y += a * 0.5 * (np.sin(2 * np.pi * f0 * r * t)
                        + np.sin(2 * np.pi * (f0 * r + 1.7) * t)) \
            * env_exp(t, tau * d)
    return y * np.minimum(t / 0.008, 1)


def shimmer(dur):
    """Lamp light: a loose cluster of pentatonic high partials that each
    swell in softly at a seeded random time, then fall away."""
    t = t_(dur)
    y = np.zeros_like(t)
    for f in (1568.0, 1760.0, 2093.0, 2349.0, 2637.0, 3136.0):
        start = RNG.uniform(0, dur * 0.45)
        tt = np.clip(t - start, 0, None)
        env = np.minimum(tt / 0.09, 1) * env_exp(tt, 0.45) * (t >= start)
        trem = 1 + 0.25 * np.sin(2 * np.pi * RNG.uniform(4, 7) * t)
        y += RNG.uniform(0.5, 1.0) * np.sin(2 * np.pi * f * t) * env * trem
    return y


def chime(dur):
    """Rising chime: four pentatonic notes, 110 ms apart, bell-ish timbre."""
    t = t_(dur)
    y = np.zeros_like(t)
    for i, f in enumerate((523.25, 659.25, 783.99, 1046.5)):
        tt = np.clip(t - i * 0.11, 0, None)
        env = np.minimum(tt / 0.004, 1) * env_exp(tt, 0.38) * (t >= i * 0.11)
        y += (np.sin(2 * np.pi * f * t) + 0.3 * np.sin(2 * np.pi * f * 2.76 * t)
              * env_exp(tt, 0.12)) * env * (0.7 + 0.1 * i)
    return y


def conch(dur):
    """Conch-like swell: reedy low tone, slow attack, light breath noise."""
    t = t_(dur)
    f0 = 233.08
    vib = 1 + 0.004 * np.sin(2 * np.pi * 5.0 * t)
    ph = 2 * np.pi * f0 * np.cumsum(vib) / SR
    tone = sum(np.sin(h * ph) / h ** 0.8 for h in range(1, 9))
    breath = lowpass(RNG.standard_normal(len(t)), 1800) * 0.25
    env = np.sin(np.clip(t / 0.9, 0, 1) * np.pi / 2) ** 2
    env *= np.clip((dur - t) / 1.0, 0, 1) ** 1.5
    return (tone + breath) * env


def swipe(dur):
    """Soft page swipe: noise through a low pass that opens then closes."""
    t = t_(dur)
    cutoff = 400 + 2600 * np.sin(np.pi * t / dur)
    n = lowpass(RNG.standard_normal(len(t)), cutoff)
    return n * np.sin(np.pi * t / dur) ** 2


def tanpura(dur, sr):
    """Four strings (Pa, Sa', Sa', Sa low) plucked once a second, circular:
    tails past the end wrap to the start, so the loop has no seam.
    Upper harmonics bloom after the pluck (the jivari buzz)."""
    sa = 130.81
    strings = [sa * 1.5, sa * 2, sa * 2, sa * 0.5]
    n = int(dur * sr)
    y = np.zeros(n)
    t_long = np.arange(n * 2) / sr          # render 2x, then fold the tail
    for k in range(int(dur)):
        f = strings[k % 4]
        tt = t_long - k * 1.0
        on = tt >= 0
        tt = np.clip(tt, 0, None)
        s = np.zeros(n * 2)
        for h in range(1, 25):
            if f * h > 9000:
                break
            bloom = min(1.0, 0.25 + h / 14)           # high partials later
            rise = np.minimum(tt / (0.02 + 0.03 * h), 1)
            swell = 1 + (bloom - 0.25) * 1.2 * np.exp(-((tt - 0.25) / 0.2) ** 2)
            s += (1 / h ** 1.1) * swell * rise \
                * np.exp(-tt / (3.2 / (1 + 0.12 * h))) \
                * np.sin(2 * np.pi * f * h * (1 + 0.0004 * h) * t_long
                         + RNG.uniform(0, 6.28))
        s *= on
        y += s[:n] + s[n:]
    return y


# --- output --------------------------------------------------------------

def write_wav(path, x, sr):
    pcm = np.clip(x, -1, 1)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes((pcm * 32767).astype("<i2").tobytes())


def to_m4a(wav, out, kbps):
    subprocess.run(
        ["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav), "-c:a", "aac",
         "-b:a", f"{kbps}k", "-movflags", "+faststart", str(out)],
        check=True)


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else \
        Path(__file__).resolve().parents[2] / "assets" / "audio"
    out.mkdir(parents=True, exist_ok=True)

    # name: (signal, peak dBFS, aac kbps, fade-out seconds)
    cues = {
        "tap":      (wood(900, 640, 0.14, 0.03), -9, 64, 0.02),
        "tok":      (wood(240, 150, 0.30, 0.07, 0.15), -7, 64, 0.04),
        "bowl":     (bowl(528.0, 2.2, 0.75), -8, 64, 0.25),
        "bell":     (bell(330.0, 3.0, 0.9), -7, 64, 0.5),
        "bell_low": (bell(196.0, 3.0, 1.1), -7, 64, 0.5),
        "shimmer":  (shimmer(1.8), -12, 64, 0.35),
        "chime":    (chime(1.6), -9, 64, 0.3),
        "conch":    (conch(2.6), -9, 64, 0.2),
        "swipe":    (swipe(0.22), -16, 48, 0.03),
    }
    with tempfile.TemporaryDirectory() as tmp:
        for name, (x, peak, kbps, fo) in cues.items():
            x = fade(norm(x, peak), SR, 0.003, fo)
            wav = Path(tmp) / f"{name}.wav"
            write_wav(wav, x, SR)
            to_m4a(wav, out / f"{name}.m4a", kbps)

    d = tanpura(8.0, SR_DRONE)
    d = norm(d - d.mean(), -9)
    write_wav(out / "drone.wav", d, SR_DRONE)
    print("wrote", out)


if __name__ == "__main__":
    main()
