import os
from PIL import Image, ImageDraw, ImageFilter

def render_apex_crest(canvas_size=1024):
    """Renders high-precision Apex Crest Emblem at 1024x1024 with antialiasing."""
    img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Base background squircle
    pad = int(canvas_size * 0.06)
    corner_r = int(canvas_size * 0.22)
    bg_box = [pad, pad, canvas_size - pad, canvas_size - pad]

    # Background gradient / rich dark surface
    draw.rounded_rectangle(bg_box, radius=corner_r, fill=(9, 13, 20, 255))

    # Inner elevation shield
    inner_pad = int(canvas_size * 0.14)
    inner_r = int(canvas_size * 0.18)
    inner_box = [inner_pad, inner_pad, canvas_size - inner_pad, canvas_size - inner_pad]
    draw.rounded_rectangle(inner_box, radius=inner_r, fill=(19, 29, 43, 255), outline=(0, 245, 160, 110), width=int(canvas_size * 0.012))

    # Scale factor mapping from 108 coordinate space
    def s(x, y):
        return (x * canvas_size / 108.0, y * canvas_size / 108.0)

    # Top-Left Winglet (Titanium Silver Metallic)
    wing_silver_pts = [
        s(42, 63),
        s(42, 46),
        s(53, 38),
        s(60, 38),
        s(49, 47),
        s(59, 47),
        s(52, 53),
        s(47, 53)
    ]
    draw.polygon(wing_silver_pts, fill=(241, 245, 249, 255))

    # Bottom-Right Winglet (Cyber Emerald Neon)
    wing_cyan_pts = [
        s(66, 45),
        s(66, 62),
        s(55, 70),
        s(48, 70),
        s(59, 61),
        s(49, 61),
        s(56, 55),
        s(61, 55)
    ]
    draw.polygon(wing_cyan_pts, fill=(0, 245, 160, 255))

    # Center Telemetry Diamond
    diamond_pts = [
        s(54, 48.5),
        s(59.5, 54),
        s(54, 59.5),
        s(48.5, 54)
    ]
    draw.polygon(diamond_pts, fill=(0, 245, 160, 255))

    # Glowing Telemetry Diode Core
    cx, cy = s(54, 54)
    diode_r = canvas_size * 0.022
    draw.ellipse([cx - diode_r, cy - diode_r, cx + diode_r, cy + diode_r], fill=(255, 255, 255, 255))

    return img

def main():
    master = render_apex_crest(1024)

    targets = [
        ("android/app/src/main/res/mipmap-mdpi/ic_launcher.png", 48),
        ("android/app/src/main/res/mipmap-hdpi/ic_launcher.png", 72),
        ("android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", 96),
        ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", 144),
        ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", 192),
        ("web/icons/Icon-192.png", 192),
        ("web/icons/Icon-512.png", 512),
        ("web/icons/Icon-maskable-192.png", 192),
        ("web/icons/Icon-maskable-512.png", 512),
        ("web/favicon.png", 64),
        ("assets/icons/ic_launcher.png", 512),
    ]

    for rel_path, dim in targets:
        os.makedirs(os.path.dirname(rel_path), exist_ok=True)
        resized = master.resize((dim, dim), Image.Resampling.LANCZOS)
        resized.save(rel_path, "PNG")
        print(f"Generated {rel_path} ({dim}x{dim})")

    print("All launcher icons generated successfully!")

if __name__ == "__main__":
    main()
