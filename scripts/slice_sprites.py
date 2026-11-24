#!/usr/bin/env python3
"""Slice approved concept art into game-ready sprite PNGs."""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ART = Path("/opt/cursor/artifacts/assets")
OUT = ROOT / "assets" / "sprites"


def save_crop(source: Path, box, dest: Path, size=None):
    image = Image.open(source).convert("RGBA")
    cropped = image.crop(box)
    if size:
        cropped = cropped.resize(size, Image.NEAREST)
    dest.parent.mkdir(parents=True, exist_ok=True)
    cropped.save(dest)
    print(f"wrote {dest} ({cropped.size[0]}x{cropped.size[1]})")


def slice_all():
    hero_src = ART / "player-bounty-hunter-style-a.png"
    villains_src = ART / "villains-match-hero-style.png"
    npcs_src = ART / "npcs-match-hero-style.png"
    fx_src = ART / "combat-fx-loot-style-a.png"

    # Hero turnaround: 4 columns x 2 rows on 1536x1024 canvas with margins.
    frame_w, frame_h = 320, 420
    start_x, start_y = 70, 90
    directions = [
        "down",
        "down_right",
        "right",
        "up_right",
        "up",
        "up_left",
        "left",
        "down_left",
    ]
    for index, name in enumerate(directions):
        col = index % 4
        row = index // 4
        x = start_x + col * 380
        y = start_y + row * 470
        save_crop(
            hero_src,
            (x, y, x + frame_w, y + frame_h),
            OUT / "hero" / f"{name}.png",
            (48, 64),
        )

    save_crop(
        hero_src,
        (start_x, start_y, start_x + frame_w, start_y + frame_h),
        OUT / "hero" / "default.png",
        (48, 64),
    )

    # Villains: three equal characters across the sheet.
    villain_boxes = [
        ("enemy_melee", (40, 120, 500, 920)),
        ("enemy_ranged", (520, 120, 980, 920)),
        ("enemy_boss", (1000, 80, 1500, 960)),
    ]
    villain_sizes = {
        "enemy_melee": (40, 48),
        "enemy_ranged": (40, 48),
        "enemy_boss": (64, 64),
    }
    for name, box in villain_boxes:
        save_crop(villains_src, box, OUT / "enemies" / f"{name}.png", villain_sizes[name])

    # NPCs: left Joe, right dealer.
    save_crop(npcs_src, (30, 120, 760, 980), OUT / "npcs" / "joe.png", (72, 72))
    save_crop(npcs_src, (780, 120, 1510, 980), OUT / "npcs" / "dealer.png", (72, 72))

    # FX sheet rows.
    fx_items = [
        ("bullet", (40, 40, 260, 120), (16, 8)),
        ("spark", (300, 30, 520, 150), (24, 24)),
        ("splatter_green", (560, 30, 780, 150), (24, 24)),
        ("splatter_red", (820, 30, 1040, 150), (24, 24)),
        ("grenade", (40, 220, 180, 360), (16, 16)),
        ("explosion_1", (220, 220, 360, 360), (32, 32)),
        ("explosion_2", (400, 220, 540, 360), (32, 32)),
        ("explosion_3", (580, 220, 720, 360), (32, 32)),
        ("explosion_4", (760, 220, 900, 360), (32, 32)),
        ("chest_common", (40, 520, 260, 760), (32, 32)),
        ("chest_rare", (300, 520, 520, 760), (32, 32)),
        ("chest_epic", (560, 520, 780, 760), (32, 32)),
        ("chest_legendary", (820, 520, 1040, 760), (32, 32)),
        ("chest_grail", (1080, 520, 1300, 760), (32, 32)),
    ]
    for name, box, size in fx_items:
        save_crop(fx_src, box, OUT / "fx" / f"{name}.png", size)

    # Combined atlases for Love2D (optional convenience sheets).
    save_crop(hero_src, (0, 0, 1536, 1024), OUT / "sheets" / "hero_sheet.png", (768, 512))
    save_crop(fx_src, (0, 0, 1536, 1024), OUT / "sheets" / "fx_sheet.png", (768, 512))


if __name__ == "__main__":
    slice_all()
