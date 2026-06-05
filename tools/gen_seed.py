# -*- coding: utf-8 -*-
"""Assemble the expanded seed data and write the JSON assets.

Run from the project root:  python3 tools/gen_seed.py
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DATA = os.path.join(ROOT, "assets", "data")
sys.path.insert(0, HERE)

from seed_data_extra import NEW_MORPHEMES, NEW_ARTICLES, build_quiz
from seed_vocab_extra import NEW_VOCAB


import shutil


BASE = os.path.join(HERE, "seed_base")


def load(name):
    """Load from an immutable base snapshot so the generator is idempotent.

    On first run, snapshots the current asset into tools/seed_base/; thereafter
    always reads that pristine copy (the live asset is the generated output)."""
    os.makedirs(BASE, exist_ok=True)
    live = os.path.join(DATA, name)
    base = os.path.join(BASE, name)
    if not os.path.exists(base):
        shutil.copyfile(live, base)
    with open(base, encoding="utf-8") as f:
        return json.load(f)


def dump(name, data):
    with open(os.path.join(DATA, name), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def main():
    morphemes = load("morphemes.json")
    vocab = load("vocabulary.json")
    articles = load("knowledge.json")

    # ── Morphemes ────────────────────────────────────────────────────────────
    next_mid = max(m["id"] for m in morphemes) + 1
    for (morph, mtype, zh, en, origin) in NEW_MORPHEMES:
        morphemes.append({
            "id": next_mid, "morpheme": morph, "type": mtype,
            "meaning_zh": zh, "meaning_en": en, "origin": origin,
        })
        next_mid += 1

    # alias -> id lookup over ALL morphemes
    alias = {}
    for m in morphemes:
        for a in m["morpheme"].split("/"):
            alias[a.strip()] = m["id"]

    # ── Vocabulary ───────────────────────────────────────────────────────────
    existing_words = {v["word"].lower() for v in vocab}
    next_vid = max(v["id"] for v in vocab) + 1
    warnings = []
    dup_words = []
    for sysid, entries in NEW_VOCAB.items():
        for (word, ipa, den, dzh, exen, exzh, diff, keys) in entries:
            if word.lower() in existing_words:
                dup_words.append(word)
            existing_words.add(word.lower())
            mids = []
            for k in keys:
                if k in alias:
                    mids.append(alias[k])
                else:
                    warnings.append(f"{word}: unknown morpheme key '{k}'")
            # de-dup while preserving order
            mids = list(dict.fromkeys(mids))
            vocab.append({
                "id": next_vid, "word": word, "ipa": ipa,
                "def_en": den, "def_zh": dzh,
                "example_en": exen, "example_zh": exzh,
                "system_id": sysid, "difficulty": diff,
                "morpheme_ids": mids,
            })
            next_vid += 1

    # ── Articles ─────────────────────────────────────────────────────────────
    next_aid = max(a["id"] for a in articles) + 1
    for (sysid, ten, tzh, diff, cen, czh) in NEW_ARTICLES:
        articles.append({
            "id": next_aid, "system_id": sysid,
            "title_en": ten, "title_zh": tzh, "difficulty": diff,
            "content_en": cen, "content_zh": czh,
        })
        next_aid += 1

    # ── Quiz (regenerated from full vocab + morphemes) ───────────────────────
    quiz = build_quiz(vocab, morphemes)

    # ── Validation ───────────────────────────────────────────────────────────
    errors = []

    def check_sequential(name, rows):
        ids = [r["id"] for r in rows]
        if ids != list(range(1, len(rows) + 1)):
            errors.append(f"{name}: ids not sequential 1..{len(rows)}")

    check_sequential("morphemes", morphemes)
    check_sequential("vocabulary", vocab)
    check_sequential("knowledge", articles)
    check_sequential("quiz", quiz)

    mid_set = {m["id"] for m in morphemes}
    for v in vocab:
        if v["system_id"] is not None and not (1 <= v["system_id"] <= 8):
            errors.append(f"vocab {v['id']} bad system_id {v['system_id']}")
        for mid in v["morpheme_ids"]:
            if mid not in mid_set:
                errors.append(f"vocab {v['id']} references missing morpheme {mid}")
    for a in articles:
        if not (1 <= a["system_id"] <= 8):
            errors.append(f"article {a['id']} bad system_id {a['system_id']}")
    vid_set = {v["id"] for v in vocab}
    for q in quiz:
        if not (0 <= q["correct_index"] < len(q["options_en"])):
            errors.append(f"quiz {q['id']} bad correct_index")
        if len(q["options_en"]) != len(q["options_zh"]):
            errors.append(f"quiz {q['id']} option length mismatch")
        if q["vocab_id"] is not None and q["vocab_id"] not in vid_set:
            errors.append(f"quiz {q['id']} bad vocab_id")
        if q["morpheme_id"] is not None and q["morpheme_id"] not in mid_set:
            errors.append(f"quiz {q['id']} bad morpheme_id")

    if dup_words:
        errors.append(f"duplicate words: {dup_words}")

    if errors:
        print("VALIDATION FAILED:")
        for e in errors:
            print("  -", e)
        sys.exit(1)

    # ── Write ────────────────────────────────────────────────────────────────
    dump("morphemes.json", morphemes)
    dump("vocabulary.json", vocab)
    dump("knowledge.json", articles)
    dump("quiz_questions.json", quiz)

    print("OK")
    print(f"  morphemes: {len(morphemes)}")
    print(f"  vocabulary: {len(vocab)}")
    print(f"  articles: {len(articles)}")
    print(f"  quiz: {len(quiz)}")
    if warnings:
        print(f"  ({len(warnings)} morpheme-key warnings; those links were skipped)")
        for w in warnings[:20]:
            print("    !", w)


if __name__ == "__main__":
    main()
