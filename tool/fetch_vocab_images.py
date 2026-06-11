#!/usr/bin/env python3
"""Fetch openly-licensed illustrations for a curated set of vocabulary words
from Wikimedia Commons into a STAGING dir, convert to WebP, and emit a montage
for visual curation. Does NOT patch vocabulary.json — that happens only after a
human culls the staging set (see tool/merge_vocab_images.py).

Attribution (artist + license) is taken from the Commons API, not guessed.
Only files whose license is in LICENSE_ALLOW are accepted.

Both raster (jpg/png) and SVG sources are supported:
  - SVG  -> qlmanage Quick Look thumbnail -> Pillow WebP
  - raster -> Pillow WebP
(macOS `sips` can read but NOT write WebP on this host, so Pillow is used for
both — this is what blocked the earlier raster-only attempt.)

Re-runnable: skips words that already have a staged .webp.
"""
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VOCAB_JSON = os.path.join(ROOT, "assets/data/vocabulary.json")
STAGING = os.path.join(ROOT, "assets/images/vocab/_staging")
API = "https://commons.wikimedia.org/w/api.php"
UA = "MedEnglish-EduApp/1.0 (vocabulary illustration pipeline; contact: app dev)"

LICENSE_ALLOW = re.compile(
    r"(CC0|public domain|CC BY(?:-SA)?(?: \d)|Creative Commons Attribution)",
    re.IGNORECASE,
)
ACCEPT_EXT = (".jpg", ".jpeg", ".png", ".svg")
BG = (248, 250, 252, 255)  # app background, for flattening transparency

# word -> Commons search query. Queries favour clean schematic diagrams over
# clinical/pathology photographs; "labeled"/"diagram" steer toward English
# educational figures. Words already drawn as house-style SVGs are excluded —
# the merge step keeps those.
TARGETS = {
    # ── Cardiovascular ──
    "pericardium": "pericardium heart anatomy diagram labeled",
    "atherosclerosis": "atherosclerosis artery plaque diagram",
    "aneurysm": "aneurysm diagram",
    "thrombosis": "thrombus blood clot diagram",
    "erythrocyte": "red blood cell diagram",
    "hemoglobin": "hemoglobin molecule diagram",
    # ── Respiratory ──
    "trachea": "trachea bronchi anatomy diagram labeled",
    "pneumothorax": "pneumothorax diagram",
    # ── Nervous ──
    "cerebrum": "cerebrum brain lobes anatomy diagram",
    "cerebellum": "cerebellum brain anatomy diagram",
    "synapse": "chemical synapse neuron diagram",
    "myelin": "myelin sheath neuron diagram",
    # ── Digestive ──
    "peristalsis": "peristalsis diagram",
    # ── Musculoskeletal ──
    "cartilage": "articular cartilage joint diagram",
    "scoliosis": "scoliosis spine diagram",
    "osteoporosis": "osteoporosis bone trabecular diagram",
    # ── Endocrine ──
    "adrenal": "adrenal gland anatomy diagram",
    "insulin": "insulin glucose regulation diagram",
    # ── Urinary ──
    "dialysis": "hemodialysis diagram",
    # ── Cell biology (strong Commons coverage) ──
    "organelle": "animal cell organelles labeled diagram",
    "nucleus": "cell nucleus diagram labeled",
    "nucleolus": "cell nucleus nucleolus diagram",
    "lysosome": "lysosome diagram",
    "Golgi apparatus": "Golgi apparatus diagram",
    "endoplasmic reticulum": "endoplasmic reticulum diagram",
    "vacuole": "vacuole plant cell diagram",
    "vesicle": "vesicle membrane transport diagram",
    "centriole": "centriole diagram",
    "cilium": "cilia structure diagram",
    "flagellum": "flagellum eukaryotic diagram",
    "microvillus": "microvilli diagram",
    "cytoskeleton": "cytoskeleton diagram",
    # ── Genetics / molecular ──
    "chromosome": "chromosome structure diagram labeled",
    "chromatin": "chromatin nucleosome diagram",
    "centromere": "chromosome centromere diagram",
    "telomere": "telomere chromosome diagram",
    "RNA": "RNA molecule structure diagram",
    "nucleotide": "nucleotide structure diagram",
    # ── Cell processes ──
    "mitosis": "mitosis phases diagram",
    "osmosis": "osmosis diagram",
    "diffusion": "diffusion across membrane diagram",
    "endocytosis": "endocytosis diagram",
    "exocytosis": "exocytosis diagram",
    "phospholipid": "phospholipid bilayer diagram",
    "plasma membrane": "cell membrane bilayer diagram",
    "enzyme": "enzyme substrate active site diagram",
}


def api_get(params):
    params = {**params, "format": "json"}
    url = API + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    for attempt in range(5):
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code == 429:
                time.sleep(3 * (attempt + 1))
                continue
            raise
    raise RuntimeError("rate limited after retries")


def search_files(query):
    data = api_get({
        "action": "query", "list": "search", "srsearch": query,
        "srnamespace": 6, "srlimit": 15,
    })
    return [h["title"] for h in data.get("query", {}).get("search", [])]


# 2-letter language codes that, when they suffix a Commons filename, signal a
# non-English-labeled diagram (e.g. "Cerebrum lobes Ar.svg", "...synapse az.jpg").
NONEN = {
    "ar", "az", "bg", "bn", "ca", "cs", "da", "de", "el", "es", "et", "eu",
    "fa", "fi", "fr", "he", "hi", "hr", "hu", "hy", "id", "it", "ja", "ka",
    "ko", "lt", "lv", "nb", "nl", "nn", "no", "pl", "pt", "ro", "ru", "sk",
    "sl", "sr", "sv", "th", "tr", "uk", "vi", "zh",
}


def lang_score(title):
    """Higher = more likely English/neutral. Penalise foreign-language suffixes."""
    low = title.lower()
    stem = re.sub(r"\.(svg|png|jpe?g)$", "", low)
    score = 0
    m = re.search(r"[ _\-]([a-z]{2})$", stem)
    if m:
        code = m.group(1)
        if code == "en":
            score += 5
        elif code in NONEN:
            score -= 6
    if re.search(r"[ _\-]en[ _\-]", low):
        score += 4
    for kw in ("diagram", "labeled", "labelled", "scheme", "schema", "anatomy"):
        if kw in low:
            score += 1
    # files explicitly tagged with another language anywhere lose a point
    if re.search(r"[ _\-](de|fr|es|ru|it|pt|pl|cs|ja|zh)[ _\-]", low):
        score -= 2
    return score


def file_info(title):
    # iiurlwidth makes the API return a server-rendered `thumburl` (a scaled
    # raster, even for SVG sources) — downloading that avoids the throttled
    # upload.wikimedia.org full-resolution endpoint and skips local rasterising.
    data = api_get({
        "action": "query", "titles": title, "prop": "imageinfo",
        "iiprop": "url|size|extmetadata", "iiurlwidth": 1000,
        "iiextmetadatafilter": "LicenseShortName|Artist|AttributionRequired",
    })
    pages = data.get("query", {}).get("pages", {})
    for p in pages.values():
        ii = p.get("imageinfo")
        if ii:
            return ii[0]
    return None


def clean_artist(raw):
    if not raw:
        return "Wikimedia Commons"
    txt = re.sub(r"<[^>]+>", "", raw)
    txt = re.sub(r"\s+", " ", txt).strip()
    return txt[:60] or "Wikimedia Commons"


def pick(query):
    """Pick the best license-OK file: rank titles by English-labeling first,
    then query imageinfo only for the top few to stay under the rate limit."""
    titles = [t for t in search_files(query) if t.lower().endswith(ACCEPT_EXT)]
    titles.sort(key=lang_score, reverse=True)
    for title in titles[:6]:
        info = file_info(title)
        if not info:
            continue
        meta = info.get("extmetadata", {})
        lic = meta.get("LicenseShortName", {}).get("value", "")
        if not LICENSE_ALLOW.search(lic):
            continue
        if info.get("width", 0) < 300:
            continue
        url = info.get("thumburl") or info["url"]
        artist = clean_artist(meta.get("Artist", {}).get("value", ""))
        return {"title": title, "url": url, "license": lic, "artist": artist}
    return None


def download(url, dest):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    for attempt in range(5):
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                data = r.read()
            with open(dest, "wb") as f:
                f.write(data)
            return
        except urllib.error.HTTPError as e:
            if e.code == 429:
                time.sleep(4 * (attempt + 1))
                continue
            raise
    raise RuntimeError("download rate limited after retries")


def to_webp(src, dest):
    # `src` is always a server-rendered raster thumbnail (PNG/JPEG).
    from PIL import Image
    im = Image.open(src).convert("RGBA")
    if max(im.size) > 900:
        im.thumbnail((900, 900), Image.LANCZOS)
    bg = Image.new("RGBA", im.size, BG)
    bg.alpha_composite(im)
    bg.convert("RGB").save(dest, "WEBP", quality=80, method=6)


def build_montage(manifest):
    """Lay out all staged webps in a labelled grid PNG for visual culling."""
    from PIL import Image, ImageDraw
    words = sorted(manifest.keys())
    if not words:
        return None
    cols = 4
    rows = (len(words) + cols - 1) // cols
    cw, ch, pad, lbl = 300, 230, 12, 22
    sheet = Image.new("RGB", (cols * (cw + pad) + pad,
                              rows * (ch + lbl + pad) + pad), (255, 255, 255))
    draw = ImageDraw.Draw(sheet)
    for i, w in enumerate(words):
        r, c = divmod(i, cols)
        x = pad + c * (cw + pad)
        y = pad + r * (ch + lbl + pad)
        try:
            thumb = Image.open(os.path.join(STAGING, f"{w}.webp")).convert("RGB")
            thumb.thumbnail((cw, ch), Image.LANCZOS)
            sheet.paste(thumb, (x + (cw - thumb.width) // 2, y))
        except Exception:  # noqa: BLE001
            draw.rectangle([x, y, x + cw, y + ch], outline=(200, 0, 0))
        draw.text((x + 2, y + ch + 2), w, fill=(0, 0, 0))
    out = os.path.join(STAGING, "_montage.png")
    sheet.save(out)
    return out


def main():
    os.makedirs(STAGING, exist_ok=True)
    vocab = json.load(open(VOCAB_JSON, encoding="utf-8"))
    by_word = {v["word"]: v for v in vocab}

    manifest_path = os.path.join(STAGING, "_manifest.json")
    manifest = {}
    if os.path.exists(manifest_path):
        manifest = json.load(open(manifest_path, encoding="utf-8"))

    def save():
        json.dump(manifest, open(manifest_path, "w", encoding="utf-8"),
                  ensure_ascii=False, indent=2)

    for word, query in TARGETS.items():
        if word not in by_word:
            print(f"SKIP {word}: not in vocabulary.json")
            continue
        webp = os.path.join(STAGING, f"{word}.webp")
        if os.path.exists(webp):
            print(f"HAVE {word}")
            continue
        time.sleep(2.0)  # be polite to the Commons API
        try:
            chosen = pick(query)
        except Exception as e:  # noqa: BLE001 — e.g. rate limit; keep going
            print(f"FAIL {word}: {e}")
            continue
        if not chosen:
            print(f"MISS {word}: no acceptable file for '{query}'")
            continue
        ext = os.path.splitext(urllib.parse.urlparse(chosen["url"]).path)[1] or ".png"
        tmp = os.path.join(STAGING, f"_{word}{ext}")
        try:
            download(chosen["url"], tmp)
            to_webp(tmp, webp)
        except Exception as e:  # noqa: BLE001
            print(f"FAIL {word}: {e}")
            continue
        finally:
            if os.path.exists(tmp):
                os.remove(tmp)
        kb = os.path.getsize(webp) // 1024
        manifest[word] = {
            "image": f"assets/images/vocab/{word}.webp",
            "image_credit": f'{chosen["artist"]} / Wikimedia Commons, {chosen["license"]}',
            "source_title": chosen["title"],
        }
        save()  # persist after every success so a throttle mid-run loses nothing
        print(f"OK   {word}: {kb}KB {chosen['license']} <- {chosen['title']}")

    save()
    montage = build_montage(manifest)
    print(f"\nStaged {len(manifest)} candidates in {STAGING}")
    if montage:
        print(f"Montage: {montage}")
    print("Review the montage, delete bad .webp files from staging, then run "
          "tool/merge_vocab_images.py to commit the keepers.")


if __name__ == "__main__":
    sys.exit(main())
