#!/usr/bin/env python3
"""Report duration, size, peak, RMS, clipping, edge levels and loop seam for
every file in assets/audio (decoded through ffmpeg, so AAC is measured as
shipped), then the main spectral peaks of each. Needs numpy and ffmpeg.
Usage: python3 tools/sound_gen/analyze.py [audio_dir]"""
import subprocess
import sys
from pathlib import Path

import numpy as np

SR = 44100


def decode(p):
    raw = subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-i", str(p), "-ac", "1", "-ar",
         str(SR), "-f", "f32le", "-"], capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype="<f4")


def db(v):
    return 20 * np.log10(max(float(v), 1e-9))


def partials(x, n=6):
    """Strongest spectral peaks (Hz) of the loudest 370 ms, and each one's
    ratio to the lowest: whole numbers = harmonic (conch, flute, tanpura),
    scattered ratios = inharmonic (bells, cymbals)."""
    hop = SR // 100
    k = int(np.argmax([np.abs(x[i:i + hop]).max() for i in range(0, len(x) - hop, hop)]))
    seg = x[k * hop:k * hop + 16384]
    seg = np.pad(seg, (0, 16384 - len(seg)))
    sp = np.abs(np.fft.rfft(seg * np.hanning(16384), 1 << 17))
    f = np.fft.rfftfreq(1 << 17, 1 / SR)
    sp[f < 60] = 0
    w = int(30 / f[1])  # a peak is the max of +-30 Hz and within 40 dB
    pk = [i for i in range(w, len(sp) - w)
          if sp[i] == sp[i - w:i + w].max() and sp[i] > sp.max() / 100]
    pk = sorted(sorted(pk, key=lambda i: -sp[i])[:n])
    return [f[i] for i in pk]


def main():
    d = Path(sys.argv[1]) if len(sys.argv) > 1 else \
        Path(__file__).resolve().parents[2] / "assets" / "audio"
    print(f"{'file':14}{'KB':>6}{'sec':>6}{'peak':>7}{'rms':>7}{'clip':>5}"
          f"{'first':>8}{'last':>8}")
    spectra = []
    for p in sorted(d.glob("*.*")):
        if p.suffix not in (".m4a", ".wav"):
            continue
        x = decode(p)
        spectra.append((p.name, partials(x)))
        n = int(0.002 * SR)
        print(f"{p.name:14}{p.stat().st_size / 1024:6.1f}{len(x) / SR:6.2f}"
              f"{db(np.abs(x).max()):7.1f}{db(np.sqrt((x ** 2).mean())):7.1f}"
              f"{int((np.abs(x) >= 0.999).sum()):5d}"
              f"{db(np.abs(x[:n]).max()):8.1f}{db(np.abs(x[-n:]).max()):8.1f}")
        if p.suffix == ".wav":
            # Loop seam: the step from the last sample to the first, against
            # the typical sample-to-sample step inside the file.
            step = abs(float(x[0] - x[-1]))
            typ = float(np.abs(np.diff(x)).mean())
            mx = float(np.abs(np.diff(x)).max())
            print(f"  loop seam step {step:.5f} vs mean step {typ:.5f}, "
                  f"max inner step {mx:.5f} -> "
                  f"{'ok' if step <= mx else 'CLICK'}")
    print("\npartials of the loudest moment: Hz (ratio to the lowest)")
    for name, fs in spectra:
        print(f"{name:14}" + "  ".join(f"{v:.0f} ({v / fs[0]:.2f})" for v in fs))


if __name__ == "__main__":
    main()
