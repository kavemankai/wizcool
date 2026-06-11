"""Procedural GBA-style SFX generator for Fringe Ledger.

Synthesises all 12 game SFX as 16-bit 44.1 kHz mono WAVs using only the
Python standard library (wave + math + random). Retro sfxr-style palette:
square/triangle/saw oscillators, white noise, pitch sweeps, fast decay
envelopes, light bit-crush for the GBA crunch.

Run:  python tools/generate_sfx.py
Out:  assets/audio/sfx/*.wav  (matches AudioManager slot names)
"""
from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

SR = 44100
OUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "sfx"

rng = random.Random(770)  # fixed seed — deterministic output


# --- oscillators / building blocks -----------------------------------------

def square(phase: float) -> float:
    return 1.0 if (phase % 1.0) < 0.5 else -1.0


def triangle(phase: float) -> float:
    p = phase % 1.0
    return 4.0 * p - 1.0 if p < 0.5 else 3.0 - 4.0 * p


def saw(phase: float) -> float:
    return 2.0 * (phase % 1.0) - 1.0


def tone(duration: float, f0: float, f1: float | None = None, osc=square,
         vol: float = 1.0) -> list[float]:
    """Oscillator with linear pitch sweep f0 -> f1 over the duration."""
    if f1 is None:
        f1 = f0
    n = int(duration * SR)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / n
        f = f0 + (f1 - f0) * t
        phase += f / SR
        out.append(osc(phase) * vol)
    return out


def noise(duration: float, lowpass: float = 1.0, vol: float = 1.0) -> list[float]:
    """White noise through a one-pole lowpass (lowpass 0..1, 1 = none)."""
    n = int(duration * SR)
    out = []
    y = 0.0
    for _ in range(n):
        y += lowpass * (rng.uniform(-1.0, 1.0) - y)
        out.append(y * vol)
    return out


def env_decay(samples: list[float], attack: float = 0.005,
              power: float = 1.5) -> list[float]:
    """Fast attack, curved decay to zero across the whole buffer."""
    n = len(samples)
    a = max(1, int(attack * SR))
    out = []
    for i, s in enumerate(samples):
        g = (i / a) if i < a else (1.0 - (i - a) / max(1, n - a)) ** power
        out.append(s * g)
    return out


def mix(*tracks: list[float]) -> list[float]:
    n = max(len(t) for t in tracks)
    return [sum(t[i] for t in tracks if i < len(t)) for i in range(n)]


def cat(*tracks: list[float]) -> list[float]:
    out: list[float] = []
    for t in tracks:
        out.extend(t)
    return out


def crush(samples: list[float], bits: int = 6) -> list[float]:
    """Bit-crush for the retro crunch."""
    q = float(1 << (bits - 1))
    return [round(s * q) / q for s in samples]


def write_wav(name: str, samples: list[float]) -> None:
    peak = max(0.001, max(abs(s) for s in samples))
    scale = 0.85 / peak  # normalise with headroom
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUT_DIR / f"{name}.wav"
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = bytearray()
        for s in samples:
            frames += struct.pack("<h", int(max(-1.0, min(1.0, s * scale)) * 32767))
        w.writeframes(bytes(frames))
    print(f"  {path.name}  ({len(samples) / SR:.2f}s)")


# --- the 12 SFX --------------------------------------------------------------

def gen_all() -> None:
    # Weapons -----------------------------------------------------------------
    # Plasma cutter: sharp electric zap — square sweep down + fizzy noise tail
    write_wav("sfx_weapon_plasma_cutter", crush(env_decay(mix(
        tone(0.28, 1800, 320, square, 0.9),
        noise(0.28, 0.6, 0.35)), power=2.2)))

    # Impact wrench: heavy low thud — triangle drop + soft noise knock
    write_wav("sfx_weapon_impact_wrench", crush(env_decay(mix(
        tone(0.24, 180, 55, triangle, 1.0),
        noise(0.08, 0.25, 0.5)), power=2.8)))

    # Long-bore drill: rising whir then crunch
    write_wav("sfx_weapon_long_bore_drill", crush(cat(
        env_decay(tone(0.32, 240, 900, saw, 0.7), attack=0.02, power=0.4),
        env_decay(mix(noise(0.18, 0.5, 1.0), tone(0.18, 140, 70, triangle, 0.6)),
                  power=2.5))))

    # Salvage pistol: dry lightweight crack
    write_wav("sfx_weapon_salvage_pistol", crush(env_decay(
        noise(0.16, 0.85, 1.0), attack=0.002, power=3.2)))

    # Gear consequences --------------------------------------------------------
    # Fracture: sharp metallic crack + descending stress groan
    write_wav("sfx_gear_fracture", crush(cat(
        env_decay(noise(0.07, 0.95, 1.0), attack=0.001, power=3.0),
        env_decay(tone(0.32, 520, 160, square, 0.55), power=1.8))))

    # Break: abrasive crunch + low collapse thud
    write_wav("sfx_gear_break", crush(cat(
        env_decay(noise(0.16, 0.7, 1.0), attack=0.002, power=2.0),
        env_decay(tone(0.3, 120, 45, triangle, 0.9), power=2.4))))

    # Unit downed: body thud + power-down hum fade
    write_wav("sfx_unit_downed", crush(cat(
        env_decay(mix(tone(0.1, 100, 60, triangle, 1.0), noise(0.06, 0.3, 0.4)),
                  power=2.5),
        env_decay(tone(0.5, 440, 60, square, 0.4), power=1.2))))

    # Field patch: applicator click + pressurised seal hiss
    write_wav("sfx_field_patch", crush(cat(
        env_decay(noise(0.02, 1.0, 1.0), attack=0.001, power=4.0),
        env_decay(noise(0.34, 0.45, 0.7), attack=0.01, power=1.4))))

    # Mission stings -----------------------------------------------------------
    # Complete: restrained rising 3-note square phrase (not a fanfare)
    write_wav("sfx_mission_complete", cat(
        env_decay(tone(0.18, 392, 392, square, 0.5), power=1.2),   # G4
        env_decay(tone(0.18, 494, 494, square, 0.5), power=1.2),   # B4
        env_decay(tone(0.5, 587, 587, square, 0.55), power=1.6)))  # D5

    # Fail: weighted descending phrase, system-shutdown register
    write_wav("sfx_mission_fail", cat(
        env_decay(tone(0.35, 220, 220, square, 0.55), power=1.2),  # A3
        env_decay(tone(0.35, 175, 175, square, 0.55), power=1.2),  # F3
        env_decay(tone(0.7, 110, 82, square, 0.6), power=1.5)))    # A2 sag

    # Interface ----------------------------------------------------------------
    # UI click: tiny clean blip
    write_wav("sfx_ui_click", env_decay(
        tone(0.045, 1400, 1100, square, 0.7), attack=0.001, power=3.0))

    # Cutaway dismiss: short soft descending sweep
    write_wav("sfx_cutaway_dismiss", env_decay(
        tone(0.14, 900, 300, triangle, 0.7), attack=0.004, power=1.8))


if __name__ == "__main__":
    print("Generating Fringe Ledger SFX ->", OUT_DIR)
    gen_all()
    print("Done.")
