#!/usr/bin/env python3
"""Fetch openly-licensed illustrations for a curated set of vocabulary words
from Wikimedia Commons, convert to WebP, and patch vocabulary.json.

Attribution (artist + license) is taken from the Commons API, not guessed.
Only files whose license is in LICENSE_ALLOW are accepted. Raster sources
only (jpg/png) so ffmpeg can convert without an SVG rasteriser.

Re-runnable: skips words that already have an image file on disk.
"""
import json
import os
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VOCAB_JSON = os.path.join(ROOT, "assets/data/vocabulary.json")
IMG_DIR = os.path.join(ROOT, "assets/images/vocab")
API = "https://commons.wikimedia.org/w/api.php"
UA = "MedEnglish-EduApp/1.0 (vocabulary illustration pipeline; contact: app dev)"

LICENSE_ALLOW = re.compile(
    r"(CC0|public domain|CC BY(?:-SA)?(?: \d)|Creative Commons Attribution)",
    re.IGNORECASE,
)
RASTER = (".jpg", ".jpeg", ".png")

# word -> Commons search query. Queries lean on "diagram"/"anatomy" to favour
# clean schematic illustrations over clinical/pathology photographs.
TARGETS = {
    "pericardium": "heart anatomy diagram labeled",
    "trachea": "trachea anatomy diagram",
    "alveolus": "pulmonary alveolus diagram",
    "cerebrum": "human brain anatomy diagram",
    "cerebellum": "cerebellum anatomy diagram",
    "synapse": "chemical synapse diagram",
    "axon": "neuron anatomy diagram",
    "nephron": "nephron diagram",
    "epidermis": "skin layers epidermis diagram",
    "cell": "animal cell diagram labeled",
    "nucleus": "cell nucleus diagram",
    "mitochondrion": "mitochondrion diagram",
    "ribosome": "ribosome diagram",
    "DNA": "DNA double helix diagram",
    "chromatid": "chromosome chromatid diagram",
    "blastocyst": "blastocyst diagram",
    "embryo": "human embryo development diagram",
    "zygote": "fertilization zygote diagram",
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
        "srnamespace": 6, "srlimit": 12,
    })
    return [h["title"] for h in data.get("query", {}).get("search", [])]


def file_info(title):
    data = api_get({
        "action": "query", "titles": title, "prop": "imageinfo",
        "iiprop": "url|size|extmetadata",
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
    for title in search_files(query):
        low = title.lower()
        if not low.endswith(RASTER):
            continue
        info = file_info(title)
        if not info:
            continue
        meta = info.get("extmetadata", {})
        lic = meta.get("LicenseShortName", {}).get("value", "")
        if not LICENSE_ALLOW.search(lic):
            continue
        w = info.get("width", 0)
        if w < 320:  # too small to be a useful illustration
            continue
        artist = clean_artist(meta.get("Artist", {}).get("value", ""))
        return {
            "title": title, "url": info["url"], "license": lic,
            "artist": artist,
        }
    return None


def download(url, dest):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r:
        data = r.read()
    with open(dest, "wb") as f:
        f.write(data)


def to_webp(src, dest):
    # macOS sips: convert to WebP, downscale so the longest side is <= 800px.
    subprocess.run(
        ["sips", "-s", "format", "webp", "-s", "formatOptions", "75",
         "-Z", "800", src, "--out", dest],
        check=True, capture_output=True,
    )


def main():
    os.makedirs(IMG_DIR, exist_ok=True)
    vocab = json.load(open(VOCAB_JSON, encoding="utf-8"))
    by_word = {v["word"]: v for v in vocab}
    results = []
    for word, query in TARGETS.items():
        v = by_word.get(word)
        if v is None:
            print(f"SKIP {word}: not in vocabulary.json")
            continue
        webp_path = os.path.join(IMG_DIR, f"{word}.webp")
        rel = f"assets/images/vocab/{word}.webp"
        if os.path.exists(webp_path):
            v["image"] = rel
            print(f"HAVE {word}")
            continue
        time.sleep(1.0)  # be polite to the Commons API
        chosen = pick(query)
        if not chosen:
            print(f"MISS {word}: no acceptable file for '{query}'")
            continue
        ext = os.path.splitext(chosen["url"])[1].lower()
        tmp = os.path.join(IMG_DIR, f"_{word}{ext}")
        try:
            download(chosen["url"], tmp)
            to_webp(tmp, webp_path)
        except Exception as e:  # noqa: BLE001
            print(f"FAIL {word}: {e}")
            continue
        finally:
            if os.path.exists(tmp):
                os.remove(tmp)
        size_kb = os.path.getsize(webp_path) // 1024
        credit = f'{chosen["artist"]} / Wikimedia Commons, {chosen["license"]}'
        v["image"] = rel
        v["image_credit"] = credit
        results.append((word, size_kb, chosen["license"], chosen["title"]))
        print(f"OK   {word}: {size_kb}KB  {chosen['license']}  <- {chosen['title']}")

    json.dump(vocab, open(VOCAB_JSON, "w", encoding="utf-8"),
              ensure_ascii=False, indent=2)
    print(f"\nWrote {len(results)} new images. vocabulary.json updated.")
    for w, kb, lic, title in results:
        print(f"  {w:14} {kb:4}KB  {lic:14} {title}")


if __name__ == "__main__":
    sys.exit(main())
