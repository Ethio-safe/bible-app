"""Generate launcher icon + splash logo for Verse Bible (no external assets).

Produces:
  assets/icon/icon.png             1024x1024 full icon (rounded gradient + open book)
  assets/icon/icon_foreground.png  1024x1024 adaptive foreground (transparent bg)
  assets/icon/splash_logo.png      512x512 splash mark
Run: python3 tools/gen_icon.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "icon"
OUT.mkdir(parents=True, exist_ok=True)

S = 1024
BG_TOP = (33, 51, 92)
BG_BOTTOM = (13, 21, 41)
GOLD = (245, 200, 92)
PAPER = (250, 247, 240)


def gradient(size, top, bottom):
    img = Image.new("RGB", (size, size), top)
    px = img.load()
    for y in range(size):
        t = y / (size - 1)
        c = tuple(int(top[i] * (1 - t) + bottom[i] * t) for i in range(3))
        for x in range(size):
            px[x, y] = c
    return img


def rounded_mask(size, radius):
    m = Image.new("L", (size, size), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, size - 1, size - 1), radius, fill=255)
    return m


def draw_book(draw: ImageDraw.ImageDraw, cx, cy, w, h, scale=1.0):
    """Open book: two pages + spine, plus a light ray for 'lamp unto my feet'."""
    w, h = w * scale, h * scale
    left = [(cx - w / 2, cy - h * 0.15), (cx - w * 0.04, cy - h * 0.05),
            (cx - w * 0.04, cy + h / 2), (cx - w / 2, cy + h * 0.4)]
    right = [(cx + w / 2, cy - h * 0.15), (cx + w * 0.04, cy - h * 0.05),
             (cx + w * 0.04, cy + h / 2), (cx + w / 2, cy + h * 0.4)]
    draw.polygon(left, fill=PAPER)
    draw.polygon(right, fill=PAPER)
    # text lines
    for i in range(4):
        y = cy + h * (0.05 + i * 0.1)
        draw.line([(cx - w * 0.42, y + h * 0.02 * i), (cx - w * 0.1, y)], fill=(200, 195, 185), width=int(10 * scale))
        draw.line([(cx + w * 0.1, y), (cx + w * 0.42, y + h * 0.02 * i)], fill=(200, 195, 185), width=int(10 * scale))
    # spine
    draw.line([(cx, cy - h * 0.05), (cx, cy + h / 2)], fill=(60, 50, 40), width=int(14 * scale))
    # golden glow above the book
    for r, a in ((h * 0.33, 40), (h * 0.26, 70), (h * 0.18, 120)):
        draw.ellipse((cx - r, cy - h * 0.4 - r, cx + r, cy - h * 0.4 + r), fill=GOLD + (a,))
    draw.ellipse((cx - h * 0.1, cy - h * 0.5, cx + h * 0.1, cy - h * 0.3), fill=GOLD + (255,))


def full_icon():
    base = gradient(S, BG_TOP, BG_BOTTOM).convert("RGBA")
    overlay = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw_book(ImageDraw.Draw(overlay, "RGBA"), S / 2, S * 0.5, S * 0.62, S * 0.5)
    base.alpha_composite(overlay)
    base.putalpha(rounded_mask(S, 220))
    base.save(OUT / "icon.png")


def foreground():
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    # Adaptive icons get masked to the inner 66%; keep the artwork small.
    draw_book(ImageDraw.Draw(img, "RGBA"), S / 2, S * 0.5, S * 0.62, S * 0.5, scale=0.68)
    img.save(OUT / "icon_foreground.png")


def splash():
    size = 512
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw_book(ImageDraw.Draw(img, "RGBA"), size / 2, size * 0.5, size * 0.7, size * 0.55, scale=0.9)
    img.save(OUT / "splash_logo.png")


if __name__ == "__main__":
    full_icon()
    foreground()
    splash()
    print("icons written to", OUT)
