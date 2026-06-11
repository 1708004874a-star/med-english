#!/usr/bin/env python3
"""Generate original, style-consistent flat 2D illustrations for a pilot set of
vocabulary words, rasterise them (qlmanage) and convert to WebP (sips), then
patch vocabulary.json.

These are original vector drawings authored for MedEnglish (no third-party
copyright), so attribution is the app itself. They are deliberately
language-neutral (no baked-in text) — the app shows bilingual labels alongside.

Pipeline is fully offline: SVG -> PNG (qlmanage Quick Look) -> WebP (sips).
"""
import json
import os
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VOCAB_JSON = os.path.join(ROOT, "assets/data/vocabulary.json")
IMG_DIR = os.path.join(ROOT, "assets/images/vocab")
CREDIT = "Illustration © MedEnglish (CC0)"

# Palette aligned with lib/core/theme/app_colors.dart
BG = "#F8FAFC"
INK = "#1E293B"
LINE = "#475569"
RED = "#EF4444"
BLUE = "#3B82F6"
PURPLE = "#8B5CF6"
GREEN = "#10B981"
AMBER = "#F59E0B"
PINK = "#EC4899"
CYAN = "#06B6D4"

W, H = 800, 600


def frame(body):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
        f'viewBox="0 0 {W} {H}">'
        f'<rect width="{W}" height="{H}" rx="0" fill="{BG}"/>'
        f"{body}</svg>"
    )


def dna():
    import math
    rungs = []
    strandA, strandB = [], []
    for i in range(0, 101):
        t = i / 100
        y = 60 + t * 480
        x = 400 + 150 * math.sin(t * math.pi * 4)
        x2 = 400 - 150 * math.sin(t * math.pi * 4)
        strandA.append(f"{x:.1f},{y:.1f}")
        strandB.append(f"{x2:.1f},{y:.1f}")
        if i % 8 == 0:
            col = [RED, BLUE, GREEN, AMBER][(i // 8) % 4]
            rungs.append(
                f'<line x1="{x:.1f}" y1="{y:.1f}" x2="{x2:.1f}" y2="{y:.1f}" '
                f'stroke="{col}" stroke-width="7" stroke-linecap="round"/>'
            )
    a = '<polyline points="' + " ".join(strandA) + (
        f'" fill="none" stroke="{PURPLE}" stroke-width="12" stroke-linecap="round"/>')
    b = '<polyline points="' + " ".join(strandB) + (
        f'" fill="none" stroke="{CYAN}" stroke-width="12" stroke-linecap="round"/>')
    return frame("".join(rungs) + a + b)


def cell():
    body = (
        f'<ellipse cx="400" cy="300" rx="320" ry="250" fill="#DBEAFE" '
        f'stroke="{BLUE}" stroke-width="8"/>'
        # nucleus
        f'<circle cx="380" cy="300" r="110" fill="#EDE9FE" stroke="{PURPLE}" stroke-width="6"/>'
        f'<circle cx="360" cy="285" r="34" fill="{PURPLE}" opacity="0.7"/>'
        # mitochondria
        f'<ellipse cx="600" cy="220" rx="70" ry="36" fill="#FEE2E2" stroke="{RED}" stroke-width="5"/>'
        f'<ellipse cx="560" cy="420" rx="62" ry="32" fill="#FEE2E2" stroke="{RED}" stroke-width="5"/>'
        # vesicles / ribosomes
        f'<circle cx="250" cy="170" r="16" fill="{GREEN}"/>'
        f'<circle cx="300" cy="460" r="14" fill="{GREEN}"/>'
        f'<circle cx="520" cy="160" r="12" fill="{AMBER}"/>'
        f'<circle cx="220" cy="380" r="20" fill="#FEF3C7" stroke="{AMBER}" stroke-width="4"/>'
    )
    return frame(body)


def mitochondrion():
    import math
    cris = []
    for i in range(7):
        x = 220 + i * 60
        cris.append(
            f'<path d="M{x},230 q 30,70 0,140" fill="none" '
            f'stroke="{RED}" stroke-width="6" stroke-linecap="round"/>'
        )
    body = (
        f'<ellipse cx="400" cy="300" rx="320" ry="160" fill="#FEE2E2" '
        f'stroke="{RED}" stroke-width="10"/>'
        f'<ellipse cx="400" cy="300" rx="290" ry="135" fill="none" '
        f'stroke="{RED}" stroke-width="4" opacity="0.5"/>'
        + "".join(cris)
    )
    return frame(body)


def neuron():
    import math
    dends = []
    for ang in range(0, 360, 45):
        r = ang * math.pi / 180
        x = 220 + 120 * math.cos(r)
        y = 300 + 120 * math.sin(r)
        dends.append(
            f'<line x1="220" y1="300" x2="{x:.0f}" y2="{y:.0f}" '
            f'stroke="{PURPLE}" stroke-width="7" stroke-linecap="round"/>'
        )
    body = (
        "".join(dends)
        # axon
        + f'<line x1="220" y1="300" x2="660" y2="300" stroke="{PURPLE}" stroke-width="14" stroke-linecap="round"/>'
        # myelin sheaths
        + f'<rect x="330" y="284" width="70" height="32" rx="16" fill="{AMBER}"/>'
        + f'<rect x="440" y="284" width="70" height="32" rx="16" fill="{AMBER}"/>'
        + f'<rect x="550" y="284" width="70" height="32" rx="16" fill="{AMBER}"/>'
        # terminals
        + f'<line x1="660" y1="300" x2="720" y2="250" stroke="{PURPLE}" stroke-width="6" stroke-linecap="round"/>'
        + f'<line x1="660" y1="300" x2="720" y2="350" stroke="{PURPLE}" stroke-width="6" stroke-linecap="round"/>'
        # soma + nucleus
        + f'<circle cx="220" cy="300" r="70" fill="#EDE9FE" stroke="{PURPLE}" stroke-width="8"/>'
        + f'<circle cx="220" cy="300" r="26" fill="{PURPLE}" opacity="0.7"/>'
    )
    return frame(body)


def alveolus():
    import math
    sacs = []
    cluster = [(300, 300, 110), (470, 230, 90), (470, 380, 95), (590, 300, 70)]
    for cx, cy, r in cluster:
        sacs.append(
            f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#DBEAFE" '
            f'stroke="{BLUE}" stroke-width="7"/>'
        )
    # bronchiole stem
    stem = (
        f'<path d="M120,300 q 60,-10 120,0" fill="none" stroke="{BLUE}" '
        f'stroke-width="26" stroke-linecap="round"/>'
    )
    # capillary
    cap = (
        f'<path d="M250,470 q 200,60 380,-40" fill="none" stroke="{RED}" '
        f'stroke-width="9" stroke-linecap="round" opacity="0.8"/>'
    )
    return frame(stem + "".join(sacs) + cap)


def epidermis():
    layers = [
        ("#FECACA", 80), ("#FCA5A5", 170), ("#FBBF24", 250),
        ("#FCD34D", 330), ("#FDE68A", 410),
    ]
    body = ""
    y = 60
    cols = ["#FDE68A", "#FCD34D", "#FBBF24", "#FCA5A5", "#F87171"]
    heights = [70, 80, 90, 110, 120]
    for col, h in zip(cols, heights):
        body += (
            f'<rect x="60" y="{y}" width="680" height="{h}" fill="{col}" '
            f'stroke="{INK}" stroke-width="1.5" opacity="0.9"/>'
        )
        y += h
    # a couple of cells dotted in top layer
    for cx in range(140, 720, 110):
        body += f'<circle cx="{cx}" cy="100" r="14" fill="#FBBF24" stroke="{INK}" stroke-width="1.5"/>'
    return frame(body)


def ribosome():
    body = (
        f'<ellipse cx="400" cy="360" rx="180" ry="120" fill="#D1FAE5" '
        f'stroke="{GREEN}" stroke-width="8"/>'
        f'<ellipse cx="400" cy="230" rx="150" ry="90" fill="#A7F3D0" '
        f'stroke="{GREEN}" stroke-width="8"/>'
        # mRNA strand threading the small subunit
        f'<line x1="120" y1="280" x2="680" y2="280" stroke="{AMBER}" '
        f'stroke-width="9" stroke-linecap="round"/>'
    )
    for x in range(150, 660, 40):
        body += f'<circle cx="{x}" cy="280" r="7" fill="{RED}"/>'
    return frame(body)


def nephron():
    body = (
        # glomerulus
        f'<circle cx="200" cy="200" r="80" fill="#FEE2E2" stroke="{RED}" stroke-width="6"/>'
        f'<path d="M160,180 q 40,-30 80,0 q -30,40 0,60 q -50,20 -80,-10 q 20,-30 0,-50" '
        f'fill="none" stroke="{RED}" stroke-width="4"/>'
        # tubule (loop of Henle)
        f'<path d="M250,250 C 420,260 420,140 540,200 '
        f'L 560,420 C 560,520 470,520 470,420 L 480,300" '
        f'fill="none" stroke="{CYAN}" stroke-width="18" stroke-linecap="round"/>'
        # collecting duct
        f'<line x1="560" y1="420" x2="640" y2="540" stroke="{BLUE}" '
        f'stroke-width="22" stroke-linecap="round"/>'
    )
    return frame(body)


def enzyme():
    # Lock-and-key: substrate (amber) docking into an enzyme's active site.
    body = (
        # enzyme body with a notched active site
        f'<path d="M180,180 h300 a40,40 0 0 1 40,40 v40 h-70 '
        f'a45,45 0 0 0 0,90 h70 v40 a40,40 0 0 1 -40,40 h-300 '
        f'a40,40 0 0 1 -40,-40 v-170 a40,40 0 0 1 40,-40 z" '
        f'fill="#D1FAE5" stroke="{GREEN}" stroke-width="8"/>'
        # substrate keying into the notch
        f'<path d="M560,235 h70 a40,40 0 0 1 0,130 h-70 '
        f'a45,45 0 0 1 0,-90 a45,45 0 0 0 0,-40 z" '
        f'fill="#FEF3C7" stroke="{AMBER}" stroke-width="7"/>'
        # motion arrow
        f'<line x1="680" y1="300" x2="600" y2="300" stroke="{INK}" '
        f'stroke-width="6" stroke-linecap="round"/>'
        f'<path d="M620,285 L600,300 L620,315" fill="none" stroke="{INK}" '
        f'stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>'
    )
    return frame(body)


def chromosome():
    # Iconic X-shaped duplicated chromosome: four chromatid arms (two sister
    # chromatids) converging at a constricted centromere.
    cx, cy = 400, 300
    arms = [(-1, -1), (1, -1), (-1, 1), (1, 1)]
    body = ""
    for sx, sy in arms:
        tip_x = cx + sx * 150
        tip_y = cy + sy * 175
        # bulge the arm outward for the classic plump chromosome look
        ctrl_x = cx + sx * 130
        ctrl_y = cy + sy * 70
        body += (
            f'<path d="M{cx},{cy} Q {ctrl_x},{ctrl_y} {tip_x},{tip_y}" '
            f'fill="none" stroke="{BLUE}" stroke-width="52" '
            f'stroke-linecap="round"/>'
        )
    # centromere constriction
    body += (
        f'<ellipse cx="{cx}" cy="{cy}" rx="60" ry="34" fill="{AMBER}" '
        f'stroke="{INK}" stroke-width="3"/>'
    )
    return frame(body)


def cilium():
    import math
    # Apical cell surface fringed with motile cilia.
    surface = (
        f'<rect x="60" y="380" width="680" height="160" fill="#DBEAFE" '
        f'stroke="{BLUE}" stroke-width="6"/>'
    )
    hairs = []
    for i, x in enumerate(range(110, 740, 70)):
        bend = 40 if i % 2 == 0 else 60
        hairs.append(
            f'<path d="M{x},380 q {bend},-120 {bend-20},-230" fill="none" '
            f'stroke="{PURPLE}" stroke-width="9" stroke-linecap="round"/>'
        )
    # basal bodies
    dots = "".join(
        f'<circle cx="{x}" cy="400" r="9" fill="{INK}"/>'
        for x in range(110, 740, 70)
    )
    return frame(surface + "".join(hairs) + dots)


def lysosome():
    # A lysosome (red vesicle of enzymes) fusing with a vesicle to digest cargo.
    body = (
        f'<circle cx="320" cy="300" r="150" fill="#FEE2E2" '
        f'stroke="{RED}" stroke-width="9"/>'
        # digestive enzymes inside
        + "".join(
            f'<path d="M{x},{y} l10,18 l-20,0 z" fill="{RED}"/>'
            for x, y in [(280, 250), (350, 270), (300, 340), (370, 330), (250, 310)]
        )
        # incoming vesicle with cargo
        + f'<circle cx="560" cy="300" r="90" fill="#FEF3C7" '
        f'stroke="{AMBER}" stroke-width="8"/>'
        + "".join(
            f'<circle cx="{x}" cy="{y}" r="12" fill="{AMBER}"/>'
            for x, y in [(540, 280), (580, 300), (555, 330)]
        )
        # fusion arrow
        + f'<line x1="470" y1="300" x2="430" y2="300" stroke="{INK}" '
        f'stroke-width="6" stroke-linecap="round"/>'
        + f'<path d="M450,288 L430,300 L450,312" fill="none" stroke="{INK}" '
        f'stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>'
    )
    return frame(body)


def osteoporosis():
    import random
    rnd = random.Random(7)
    # Healthy dense bone (left) vs porous osteoporotic bone (right).
    def block(x0, holes, label_color):
        rects = (
            f'<rect x="{x0}" y="120" width="260" height="360" rx="24" '
            f'fill="#FDE68A" stroke="{INK}" stroke-width="4"/>'
        )
        pores = ""
        for _ in range(holes):
            cx = x0 + 30 + rnd.random() * 200
            cy = 150 + rnd.random() * 300
            r = 8 + rnd.random() * (22 if holes > 40 else 9)
            pores += f'<circle cx="{cx:.0f}" cy="{cy:.0f}" r="{r:.0f}" fill="{BG}"/>'
        return rects + pores
    body = block(70, 36, INK) + block(470, 70, RED)
    return frame(body)


def aneurysm():
    # A blood vessel with a balloon-like bulge (aneurysm) in its wall.
    body = (
        f'<path d="M80,330 h240 q40,0 60,-40 q40,-130 120,-130 '
        f'q80,0 120,130 q20,40 60,40 h160" fill="none" stroke="{RED}" '
        f'stroke-width="46" stroke-linecap="round"/>'
        # lumen highlight
        f'<path d="M80,330 h560" fill="none" stroke="#FCA5A5" '
        f'stroke-width="14" stroke-linecap="round" opacity="0.7"/>'
        # the bulge sac outline
        f'<circle cx="440" cy="190" r="86" fill="#FEE2E2" '
        f'stroke="{RED}" stroke-width="8"/>'
    )
    return frame(body)


PILOT = {
    "DNA": dna,
    "cell": cell,
    "mitochondrion": mitochondrion,
    "axon": neuron,
    "alveolus": alveolus,
    "epidermis": epidermis,
    "ribosome": ribosome,
    "nephron": nephron,
    "enzyme": enzyme,
    "chromosome": chromosome,
    "cilium": cilium,
    "lysosome": lysosome,
    "osteoporosis": osteoporosis,
    "aneurysm": aneurysm,
}


def rasterise(svg_text, webp_path):
    with tempfile.TemporaryDirectory() as td:
        svg_path = os.path.join(td, "in.svg")
        with open(svg_path, "w", encoding="utf-8") as f:
            f.write(svg_text)
        # qlmanage renders a thumbnail PNG of the SVG.
        subprocess.run(
            ["qlmanage", "-t", "-s", "800", "-o", td, svg_path],
            check=True, capture_output=True,
        )
        png_path = os.path.join(td, "in.svg.png")
        if not os.path.exists(png_path):
            raise RuntimeError("qlmanage produced no PNG")
        # sips on this macOS can read but not write WebP; use Pillow instead.
        from PIL import Image
        im = Image.open(png_path).convert("RGBA")
        if max(im.size) > 800:
            im.thumbnail((800, 800), Image.LANCZOS)
        bg = Image.new("RGBA", im.size, (248, 250, 252, 255))
        bg.alpha_composite(im)
        bg.convert("RGB").save(webp_path, "WEBP", quality=80, method=6)


def main():
    os.makedirs(IMG_DIR, exist_ok=True)
    vocab = json.load(open(VOCAB_JSON, encoding="utf-8"))
    by_word = {v["word"]: v for v in vocab}
    done = []
    for word, fn in PILOT.items():
        v = by_word.get(word)
        if v is None:
            print(f"SKIP {word}: not in vocabulary.json")
            continue
        webp_path = os.path.join(IMG_DIR, f"{word}.webp")
        rel = f"assets/images/vocab/{word}.webp"
        try:
            rasterise(fn(), webp_path)
        except Exception as e:  # noqa: BLE001
            print(f"FAIL {word}: {e}")
            continue
        v["image"] = rel
        v["image_credit"] = CREDIT
        kb = os.path.getsize(webp_path) // 1024
        done.append((word, kb))
        print(f"OK   {word}: {kb}KB")
    json.dump(vocab, open(VOCAB_JSON, "w", encoding="utf-8"),
              ensure_ascii=False, indent=2)
    print(f"\nWrote {len(done)} illustrations; vocabulary.json updated.")


if __name__ == "__main__":
    sys.exit(main())
