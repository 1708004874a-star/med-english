#!/usr/bin/env python3
"""Commit curated staging images into the live asset dir and patch
vocabulary.json.

Workflow:
  1. tool/fetch_vocab_images.py  -> downloads candidates to _staging/ + manifest
  2. review _staging/_montage.png -> delete the .webp files you DON'T want
  3. this script                 -> moves the SURVIVING .webp files into
                                    assets/images/vocab/ and writes their
                                    image/image_credit onto vocabulary.json

A staging entry is only committed if BOTH its .webp file still exists (i.e. it
survived culling) and it has a manifest record (for the credit string). Words
already illustrated by house-style SVGs are untouched.
"""
import json
import os
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VOCAB_JSON = os.path.join(ROOT, "assets/data/vocabulary.json")
IMG_DIR = os.path.join(ROOT, "assets/images/vocab")
STAGING = os.path.join(IMG_DIR, "_staging")


def main():
    manifest_path = os.path.join(STAGING, "_manifest.json")
    if not os.path.exists(manifest_path):
        print("No staging manifest; run fetch_vocab_images.py first.")
        return 1
    manifest = json.load(open(manifest_path, encoding="utf-8"))
    vocab = json.load(open(VOCAB_JSON, encoding="utf-8"))
    by_word = {v["word"]: v for v in vocab}

    committed = []
    for word, rec in manifest.items():
        staged = os.path.join(STAGING, f"{word}.webp")
        if not os.path.exists(staged):
            print(f"CULLED {word} (no staged file)")
            continue
        v = by_word.get(word)
        if v is None:
            print(f"SKIP {word}: not in vocabulary.json")
            continue
        # Slugify: Flutter asset paths with spaces are fragile.
        slug = word.replace(" ", "_")
        dest = os.path.join(IMG_DIR, f"{slug}.webp")
        shutil.copyfile(staged, dest)
        v["image"] = f"assets/images/vocab/{slug}.webp"
        v["image_credit"] = rec["image_credit"]
        committed.append(word)
        print(f"OK {word}: {rec['image_credit']}")

    json.dump(vocab, open(VOCAB_JSON, "w", encoding="utf-8"),
              ensure_ascii=False, indent=2)
    print(f"\nCommitted {len(committed)} real images: {committed}")
    print("Remember to bump kSeedVersion in lib/core/constants/db_constants.dart")
    return 0


if __name__ == "__main__":
    sys.exit(main())
