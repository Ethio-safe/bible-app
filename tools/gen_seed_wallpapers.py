#!/usr/bin/env python3
"""Generate original abstract seed wallpapers (WebP) for the bundled pool.

Deterministic; safe to re-run. Output: assets/wallpapers/seed/seed_NN.webp
plus seed_manifest.json describing each image (palette / mood / dark flag).
"""
from __future__ import annotations

import json
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

W, H = 1080, 1920
OUT = Path(__file__).resolve().parent.parent / "assets" / "wallpapers" / "seed"

# (name, mood, [stops as hex], dark)
PALETTES = [
    ("dawn", "warm", ["#2b1055", "#7597de", "#f8c291"], True),
    ("ocean", "cool", ["#021b3a", "#0f4c81", "#3fa7d6"], True),
    ("forest", "calm", ["#0b2e13", "#1e5631", "#a4de02"], True),
    ("ember", "warm", ["#1a0000", "#7a1f1f", "#ff8c42"], True),
    ("lavender", "soft", ["#3a2a5e", "#9d84c9", "#f2e9ff"], False),
    ("mist", "soft", ["#5b6d7a", "#a9b8c2", "#eef3f6"], False),
    ("sunset", "warm", ["#2d1b4e", "#c94b4b", "#ffb75e"], True),
    ("midnight", "cool", ["#000428", "#004e92", "#1c1c3c"], True),
    ("sand", "soft", ["#8d6e4f", "#d9b99b", "#f7efe5"], False),
    ("aurora", "cool", ["#031b2a", "#0f7f7a", "#c2f970"], True),
    ("rose", "warm", ["#4a1942", "#c33764", "#f9d6d2"], False),
    ("slate", "calm", ["#0f172a", "#334155", "#94a3b8"], True),
    ("meadow", "calm", ["#1b4332", "#52b788", "#d8f3dc"], False),
    ("plum", "soft", ["#240b36", "#6b2d5c", "#c31432"], True),
    ("gold", "warm", ["#3d2c00", "#b8860b", "#fff1c1"], False),
]


def hex_to_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore


def gradient(stops: list[str], angle_deg: float) -> np.ndarray:
    cols = np.array([hex_to_rgb(s) for s in stops], dtype=np.float32)
    ys, xs = np.mgrid[0:H, 0:W].astype(np.float32)
    a = math.radians(angle_deg)
    t = (xs / W) * math.cos(a) + (ys / H) * math.sin(a)
    t = (t - t.min()) / (t.max() - t.min() + 1e-6)
    n = len(cols) - 1
    idx = np.clip((t * n).astype(int), 0, n - 1)
    frac = (t * n - idx)[..., None]
    return cols[idx] * (1 - frac) + cols[idx + 1] * frac


def bokeh(img: Image.Image, rng: random.Random, tint: tuple[int, int, int], n: int) -> Image.Image:
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for _ in range(n):
        r = rng.randint(60, 340)
        x, y = rng.randint(-r, W + r), rng.randint(-r, H + r)
        alpha = rng.randint(18, 60)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(*tint, alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(rng.randint(30, 90)))
    return Image.alpha_composite(img.convert("RGBA"), layer)


def waves(img: Image.Image, rng: random.Random, tint: tuple[int, int, int]) -> Image.Image:
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for k in range(6):
        base = H * (0.45 + 0.09 * k)
        amp = rng.randint(40, 120)
        pts = [(x, base + amp * math.sin(x / rng.uniform(140, 260) + k)) for x in range(0, W + 20, 20)]
        pts += [(W, H), (0, H)]
        d.polygon(pts, fill=(*tint, 14 + k * 4))
    layer = layer.filter(ImageFilter.GaussianBlur(6))
    return Image.alpha_composite(img.convert("RGBA"), layer)


def grain(arr: np.ndarray, rng: np.random.Generator, amount: float = 6.0) -> np.ndarray:
    return np.clip(arr + rng.normal(0, amount, arr.shape), 0, 255)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    manifest = []
    for i, (name, mood, stops, dark) in enumerate(PALETTES, start=1):
        rng = random.Random(1000 + i)
        nrng = np.random.default_rng(1000 + i)
        arr = gradient(stops, rng.uniform(55, 125))
        arr = grain(arr, nrng)
        img = Image.fromarray(arr.astype(np.uint8), "RGB")
        light = hex_to_rgb(stops[-1])
        if i % 3 == 0:
            img = waves(img, rng, light)
        img = bokeh(img, rng, light, rng.randint(8, 16))
        img = img.convert("RGB")
        # Slight vignette to help text legibility at the edges.
        vign = Image.new("L", (W, H), 0)
        ImageDraw.Draw(vign).ellipse((-W * 0.25, -H * 0.15, W * 1.25, H * 1.15), fill=255)
        vign = vign.filter(ImageFilter.GaussianBlur(220))
        dark_layer = Image.new("RGB", (W, H), (0, 0, 0))
        img = Image.composite(img, Image.blend(img, dark_layer, 0.35), vign)

        fname = f"seed_{i:02d}.webp"
        img.save(OUT / fname, "WEBP", quality=82, method=6)
        manifest.append({"file": fname, "name": name, "mood": mood, "dark": dark})
        print("wrote", fname)

    (OUT / "seed_manifest.json").write_text(json.dumps(manifest, indent=2))
    total = sum(p.stat().st_size for p in OUT.glob("*.webp"))
    print(f"{len(manifest)} images, {total/1024/1024:.1f} MB total")


if __name__ == "__main__":
    main()
