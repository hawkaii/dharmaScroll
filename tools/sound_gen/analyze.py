#!/usr/bin/env python3
"""Report duration, size, peak, RMS, clipping, edge levels and loop seam for
every file in assets/audio (decoded through ffmpeg, so AAC is measured as
shipped). Usage: python3 tools/sound_gen/analyze.py [audio_dir]"""
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


def main():
    d = Path(sys.argv[1]) if len(sys.argv) > 1 else \
        Path(__file__).resolve().parents[2] / "assets" / "audio"
    print(f"{'file':14}{'KB':>6}{'sec':>6}{'peak':>7}{'rms':>7}{'clip':>5}"
          f"{'first':>8}{'last':>8}")
    for p in sorted(d.glob("*.*")):
        if p.suffix not in (".m4a", ".wav"):
            continue
        x = decode(p)
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


if __name__ == "__main__":
    main()
