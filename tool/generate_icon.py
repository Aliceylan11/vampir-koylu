"""
Vampir Köylü uygulama ikonu üreticisi.

Çıktılar:
  assets/icon/icon.png         - 1024x1024 ana ikon (flutter_launcher_icons için)
  assets/icon/icon_fg.png      - 1024x1024 adaptive foreground (saydam arkaplan)

Çalıştırmak için:
  python tool/generate_icon.py
"""
from __future__ import annotations

import math
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


# ============== RENKLER (oyunun tema paletiyle birebir) ==============
BG_TOP = (10, 6, 19)         # #0A0613 - derin gece moru
BG_MID = (26, 15, 46)        # #1A0F2E - karanlık menekşe
BG_BOT = (42, 27, 71)        # #2A1B47 - yüksek menekşe
MOON_COLOR = (228, 195, 95)  # parlak altın
MOON_GLOW = (255, 220, 140)  # altın halo
BAT_COLOR = (8, 4, 14)       # neredeyse siyah - silüet
BLOOD = (139, 0, 0)          # koyu kan kırmızısı
BLOOD_BRIGHT = (178, 34, 34) # parlak kan
GOLD = (212, 175, 55)        # eski altın

SIZE = 1024


def vertical_gradient(width: int, height: int, top: tuple[int, int, int],
                      mid: tuple[int, int, int], bot: tuple[int, int, int]) -> Image.Image:
    """3-stop dikey gradient."""
    img = Image.new("RGB", (width, height), top)
    px = img.load()
    half = height // 2
    for y in range(height):
        if y < half:
            t = y / half
            r = int(top[0] + (mid[0] - top[0]) * t)
            g = int(top[1] + (mid[1] - top[1]) * t)
            b = int(top[2] + (mid[2] - top[2]) * t)
        else:
            t = (y - half) / (height - half)
            r = int(mid[0] + (bot[0] - mid[0]) * t)
            g = int(mid[1] + (bot[1] - mid[1]) * t)
            b = int(mid[2] + (bot[2] - mid[2]) * t)
        for x in range(width):
            px[x, y] = (r, g, b)
    return img


def draw_moon(img: Image.Image, cx: float, cy: float, r: float) -> None:
    """Parlak dolunay + halo + krater detayları."""
    # Halo (büyük yumuşak ışık)
    halo = Image.new("RGBA", img.size, (0, 0, 0, 0))
    halo_draw = ImageDraw.Draw(halo)
    halo_draw.ellipse(
        [cx - r * 1.7, cy - r * 1.7, cx + r * 1.7, cy + r * 1.7],
        fill=(MOON_GLOW[0], MOON_GLOW[1], MOON_GLOW[2], 90),
    )
    halo = halo.filter(ImageFilter.GaussianBlur(radius=60))
    img.paste(halo, (0, 0), halo)

    # İkinci halo (daha sıkı)
    halo2 = Image.new("RGBA", img.size, (0, 0, 0, 0))
    halo2_draw = ImageDraw.Draw(halo2)
    halo2_draw.ellipse(
        [cx - r * 1.25, cy - r * 1.25, cx + r * 1.25, cy + r * 1.25],
        fill=(MOON_GLOW[0], MOON_GLOW[1], MOON_GLOW[2], 130),
    )
    halo2 = halo2.filter(ImageFilter.GaussianBlur(radius=30))
    img.paste(halo2, (0, 0), halo2)

    # Asıl ay
    draw = ImageDraw.Draw(img)
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=MOON_COLOR)

    # Krater detayları
    craters = [
        (cx - r * 0.35, cy - r * 0.15, r * 0.13),
        (cx + r * 0.25, cy - r * 0.30, r * 0.08),
        (cx - r * 0.10, cy + r * 0.35, r * 0.10),
        (cx + r * 0.40, cy + r * 0.20, r * 0.06),
        (cx - r * 0.50, cy + r * 0.45, r * 0.05),
    ]
    crater_color = (190, 160, 70)
    for x, y, rr in craters:
        draw.ellipse([x - rr, y - rr, x + rr, y + rr], fill=crater_color)


def bat_silhouette(cx: float, cy: float, scale: float) -> list[tuple[float, float]]:
    """
    Yayılmış kanatlarıyla stilize bir yarasa silüeti.
    cx, cy: merkez
    scale: genişlik birimi (yarım açıklık)

    Tasarım: keskin uçlu kanatlar (sivri parmaklar) +
    yuvarlak gövde + iki sivri kulak.
    """
    s = scale
    # Sol kanat → gövde → sağ kanat polygon noktaları sırayla
    pts = [
        # Sol kanat alt çıkıntıları
        (cx - 2.00 * s, cy + 0.15 * s),   # sol alt uç
        (cx - 1.65 * s, cy + 0.25 * s),   # iç vadi
        (cx - 1.50 * s, cy + 0.55 * s),   # alt sarkma
        (cx - 1.20 * s, cy + 0.30 * s),   # vadi
        (cx - 1.00 * s, cy + 0.65 * s),   # alt sarkma 2
        (cx - 0.70 * s, cy + 0.35 * s),   # vadi
        (cx - 0.45 * s, cy + 0.75 * s),   # gövde alt sol

        # Gövde alt
        (cx, cy + 0.85 * s),              # gövde dibi
        (cx + 0.45 * s, cy + 0.75 * s),   # gövde alt sağ

        # Sağ kanat alt çıkıntıları (simetrik)
        (cx + 0.70 * s, cy + 0.35 * s),
        (cx + 1.00 * s, cy + 0.65 * s),
        (cx + 1.20 * s, cy + 0.30 * s),
        (cx + 1.50 * s, cy + 0.55 * s),
        (cx + 1.65 * s, cy + 0.25 * s),
        (cx + 2.00 * s, cy + 0.15 * s),   # sağ alt uç

        # Sağ kanat üst
        (cx + 1.50 * s, cy - 0.20 * s),
        (cx + 1.05 * s, cy - 0.10 * s),
        (cx + 0.55 * s, cy - 0.30 * s),

        # Sağ kulak
        (cx + 0.35 * s, cy - 0.50 * s),
        (cx + 0.20 * s, cy - 0.85 * s),
        (cx + 0.08 * s, cy - 0.55 * s),

        # Tepe çukurluk
        (cx, cy - 0.45 * s),

        # Sol kulak
        (cx - 0.08 * s, cy - 0.55 * s),
        (cx - 0.20 * s, cy - 0.85 * s),
        (cx - 0.35 * s, cy - 0.50 * s),

        # Sol kanat üst
        (cx - 0.55 * s, cy - 0.30 * s),
        (cx - 1.05 * s, cy - 0.10 * s),
        (cx - 1.50 * s, cy - 0.20 * s),
    ]
    return pts


def draw_bat(img: Image.Image, cx: float, cy: float, scale: float,
             color: tuple[int, int, int] = BAT_COLOR) -> None:
    """Yarasa silüetini çiz."""
    draw = ImageDraw.Draw(img)
    pts = bat_silhouette(cx, cy, scale)
    draw.polygon(pts, fill=color)

    # Hafif gölge için kanat altına koyu yansıma
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.polygon(pts, fill=(0, 0, 0, 100))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=8))
    img.paste(shadow, (8, 14), shadow)
    draw.polygon(pts, fill=color)

    # Küçük kırmızı gözler
    eye_y = cy - 0.30 * scale
    eye_off = 0.16 * scale
    eye_r = 0.05 * scale
    for sign in (-1, 1):
        ex = cx + sign * eye_off
        draw.ellipse(
            [ex - eye_r, eye_y - eye_r, ex + eye_r, eye_y + eye_r],
            fill=BLOOD_BRIGHT,
        )


def draw_blood_drop(img: Image.Image, cx: float, cy: float, scale: float) -> None:
    """Damla şeklinde bir kan damlası."""
    draw = ImageDraw.Draw(img)
    s = scale
    # Damla = üst sivri ucu olan polygon + alt yuvarlak ellipse
    drop = [
        (cx, cy - 1.0 * s),
        (cx - 0.25 * s, cy - 0.3 * s),
        (cx - 0.55 * s, cy + 0.2 * s),
        (cx - 0.55 * s, cy + 0.55 * s),
        (cx - 0.35 * s, cy + 0.85 * s),
        (cx, cy + 0.95 * s),
        (cx + 0.35 * s, cy + 0.85 * s),
        (cx + 0.55 * s, cy + 0.55 * s),
        (cx + 0.55 * s, cy + 0.2 * s),
        (cx + 0.25 * s, cy - 0.3 * s),
    ]
    # Gölge
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.polygon([(p[0] + 4, p[1] + 6) for p in drop],
                  fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=3))
    img.paste(shadow, (0, 0), shadow)

    draw.polygon(drop, fill=BLOOD)
    # Parlak nokta (highlight)
    draw.ellipse(
        [cx - 0.15 * s, cy + 0.15 * s,
         cx - 0.05 * s, cy + 0.32 * s],
        fill=(220, 80, 80),
    )


def draw_gold_border(img: Image.Image, thickness: int = 12,
                     inset: int = 38) -> None:
    """Dış altın çerçeve — gotik vurgu."""
    draw = ImageDraw.Draw(img, "RGBA")
    w, h = img.size
    rect = [inset, inset, w - inset, h - inset]
    draw.rounded_rectangle(
        rect, radius=140, outline=(GOLD[0], GOLD[1], GOLD[2], 180),
        width=thickness,
    )


# ============== ANA İKON ==============
def build_main_icon() -> Image.Image:
    img = vertical_gradient(SIZE, SIZE, BG_TOP, BG_MID, BG_BOT)

    # Köşelere hafif yıldız serpiştir
    star_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(star_layer)
    import random
    random.seed(42)
    for _ in range(60):
        x = random.randint(0, SIZE)
        y = random.randint(0, int(SIZE * 0.55))
        r = random.choice([1, 1, 2, 2, 3])
        a = random.randint(60, 180)
        sdraw.ellipse([x - r, y - r, x + r, y + r],
                      fill=(255, 245, 200, a))
    img.paste(star_layer, (0, 0), star_layer)

    # Dolunay
    moon_r = SIZE * 0.32
    moon_cx = SIZE / 2
    moon_cy = SIZE * 0.46
    draw_moon(img, moon_cx, moon_cy, moon_r)

    # Yarasa (dolunayın önünde)
    draw_bat(img, moon_cx, moon_cy + SIZE * 0.02, scale=SIZE * 0.18)

    # Altta kan damlaları
    drop_y = SIZE * 0.88
    drop_scale = SIZE * 0.05
    draw_blood_drop(img, SIZE * 0.36, drop_y, drop_scale)
    draw_blood_drop(img, SIZE * 0.50, drop_y + SIZE * 0.02, drop_scale * 1.2)
    draw_blood_drop(img, SIZE * 0.64, drop_y, drop_scale)

    # Altın çerçeve
    draw_gold_border(img, thickness=10, inset=42)

    return img


# ============== ADAPTIVE FOREGROUND (saydam) ==============
def build_foreground_icon() -> Image.Image:
    """Android adaptive icon için saydam arkaplanlı foreground."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

    # Sadece dolunay + yarasa (arkaplan saydam)
    moon_r = SIZE * 0.26
    moon_cx = SIZE / 2
    moon_cy = SIZE * 0.50

    # Halo
    halo = Image.new("RGBA", img.size, (0, 0, 0, 0))
    halo_draw = ImageDraw.Draw(halo)
    halo_draw.ellipse(
        [moon_cx - moon_r * 1.2, moon_cy - moon_r * 1.2,
         moon_cx + moon_r * 1.2, moon_cy + moon_r * 1.2],
        fill=(MOON_GLOW[0], MOON_GLOW[1], MOON_GLOW[2], 100),
    )
    halo = halo.filter(ImageFilter.GaussianBlur(radius=30))
    img.paste(halo, (0, 0), halo)

    draw = ImageDraw.Draw(img)
    draw.ellipse(
        [moon_cx - moon_r, moon_cy - moon_r,
         moon_cx + moon_r, moon_cy + moon_r],
        fill=MOON_COLOR,
    )
    draw_bat(img, moon_cx, moon_cy + SIZE * 0.01, scale=SIZE * 0.15)

    return img


def main() -> None:
    # Windows konsol UTF-8 desteklemiyor olabilir, ASCII print kullan.
    project_root = Path(__file__).resolve().parent.parent
    out_dir = project_root / "assets" / "icon"
    out_dir.mkdir(parents=True, exist_ok=True)

    main_icon = build_main_icon()
    main_path = out_dir / "icon.png"
    main_icon.save(main_path, "PNG", optimize=True)
    print(f"[OK] Ana ikon yazildi: {main_path}")

    fg_icon = build_foreground_icon()
    fg_path = out_dir / "icon_fg.png"
    fg_icon.save(fg_path, "PNG", optimize=True)
    print(f"[OK] Foreground ikon yazildi: {fg_path}")

    # Önizleme için 256'lık küçük versiyon
    preview = main_icon.resize((256, 256), Image.LANCZOS)
    preview_path = out_dir / "icon_preview.png"
    preview.save(preview_path, "PNG", optimize=True)
    print(f"[OK] Onizleme yazildi: {preview_path}")


if __name__ == "__main__":
    main()
