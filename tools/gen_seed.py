# -*- coding: utf-8 -*-
"""Assemble the expanded seed data and write the JSON assets.

Run from the project root:  python3 tools/gen_seed.py
"""
import json
import os
import sys
import shutil

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DATA = os.path.join(ROOT, "assets", "data")
sys.path.insert(0, HERE)

from seed_data_extra import NEW_MORPHEMES, NEW_ARTICLES, build_quiz
from seed_vocab_extra import NEW_VOCAB
from seed_micro_extra import MICRO_MORPHEMES, MICRO_VOCAB, MICRO_ARTICLES

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


def build_alias_map(morphemes):
    """Build alias->id lookup from a list of morpheme dicts."""
    alias = {}
    for m in morphemes:
        for a in m["morpheme"].split("/"):
            alias[a.strip()] = m["id"]
    return alias


def main():
    morphemes = load("morphemes.json")
    vocab = load("vocabulary.json")
    articles = load("knowledge.json")

    # ── Tag all base records with domain='macro' ──────────────────────────
    for m in morphemes:
        m["domain"] = "macro"
    for v in vocab:
        v["domain"] = "macro"
    for a in articles:
        a["domain"] = "macro"

    # ── Morphemes ─────────────────────────────────────────────────────────
    # Macro morphemes: base (already tagged) + NEW_MORPHEMES
    next_mid = max(m["id"] for m in morphemes) + 1
    for (morph, mtype, zh, en, origin) in NEW_MORPHEMES:
        morphemes.append({
            "id": next_mid, "morpheme": morph, "type": mtype,
            "meaning_zh": zh, "meaning_en": en, "origin": origin,
            "domain": "macro",
        })
        next_mid += 1

    # Micro morphemes: append with domain='micro', sequential ids
    for (morph, mtype, zh, en, origin) in MICRO_MORPHEMES:
        morphemes.append({
            "id": next_mid, "morpheme": morph, "type": mtype,
            "meaning_zh": zh, "meaning_en": en, "origin": origin,
            "domain": "micro",
        })
        next_mid += 1

    # ── Domain-scoped alias maps ──────────────────────────────────────────
    macro_morphemes = [m for m in morphemes if m["domain"] == "macro"]
    micro_morphemes = [m for m in morphemes if m["domain"] == "micro"]
    macro_alias = build_alias_map(macro_morphemes)
    micro_alias = build_alias_map(micro_morphemes)

    # ── Vocabulary ────────────────────────────────────────────────────────
    # word -> domain it was first seen in (cross-domain duplicates are OK)
    existing_words = {v["word"].lower(): v.get("domain", "macro")
                      for v in vocab}
    next_vid = max(v["id"] for v in vocab) + 1
    warnings = []
    dup_words = []

    # Helper: append vocab entries, resolving morpheme keys against the
    # given alias map.
    def append_vocab(entries, domain, alias_map):
        nonlocal next_vid
        for sysid, words in entries.items():
            for (word, ipa, den, dzh, exen, exzh, diff, keys) in words:
                wlower = word.lower()
                if wlower in existing_words:
                    if existing_words[wlower] == domain:
                        dup_words.append(f"{word} ({domain})")
                else:
                    existing_words[wlower] = domain
                mids = []
                for k in keys:
                    if k in alias_map:
                        mids.append(alias_map[k])
                    else:
                        warnings.append(
                            f"{word} ({domain}): unknown morpheme key '{k}'")
                # de-dup while preserving order
                mids = list(dict.fromkeys(mids))
                vocab.append({
                    "id": next_vid, "word": word, "ipa": ipa,
                    "def_en": den, "def_zh": dzh,
                    "example_en": exen, "example_zh": exzh,
                    "system_id": sysid, "difficulty": diff,
                    "morpheme_ids": mids,
                    "domain": domain,
                })
                next_vid += 1

    # Macro vocab (resolve against macro alias)
    append_vocab(NEW_VOCAB, "macro", macro_alias)

    # Micro vocab (resolve against micro alias only)
    append_vocab(MICRO_VOCAB, "micro", micro_alias)

    # ── Articles ──────────────────────────────────────────────────────────
    next_aid = max(a["id"] for a in articles) + 1

    # Macro articles
    for (sysid, ten, tzh, diff, cen, czh) in NEW_ARTICLES:
        articles.append({
            "id": next_aid, "system_id": sysid,
            "title_en": ten, "title_zh": tzh, "difficulty": diff,
            "content_en": cen, "content_zh": czh,
            "domain": "macro",
        })
        next_aid += 1

    # Micro articles
    for (sysid, ten, tzh, diff, cen, czh) in MICRO_ARTICLES:
        articles.append({
            "id": next_aid, "system_id": sysid,
            "title_en": ten, "title_zh": tzh, "difficulty": diff,
            "content_en": cen, "content_zh": czh,
            "domain": "micro",
        })
        next_aid += 1

    # ── Quiz (regenerated, partitioned by domain) ─────────────────────────
    macro_vocab = [v for v in vocab if v["domain"] == "macro"]
    micro_vocab = [v for v in vocab if v["domain"] == "micro"]

    quiz = build_quiz(macro_vocab, macro_morphemes,
                      domain="macro", seed=42, start_id=1)
    next_qid = len(quiz) + 1
    quiz += build_quiz(micro_vocab, micro_morphemes,
                       domain="micro", seed=42, start_id=next_qid)

    # ── Validation ────────────────────────────────────────────────────────
    errors = []

    def check_sequential(name, rows):
        ids = [r["id"] for r in rows]
        if ids != list(range(1, len(rows) + 1)):
            errors.append(f"{name}: ids not sequential 1..{len(rows)}")

    check_sequential("morphemes", morphemes)
    check_sequential("vocabulary", vocab)
    check_sequential("knowledge", articles)
    check_sequential("quiz", quiz)

    # Domain field present on all records
    for label, rows in [("morphemes", morphemes), ("vocabulary", vocab),
                        ("knowledge", articles), ("quiz", quiz)]:
        for r in rows:
            if "domain" not in r or r["domain"] not in ("macro", "micro"):
                errors.append(f"{label} id {r['id']}: missing or invalid domain")

    # Domain-consistency: vocab morpheme_ids must reference same-domain morphemes
    mid_domain = {m["id"]: m["domain"] for m in morphemes}
    for v in vocab:
        if v["system_id"] is not None and not (1 <= v["system_id"] <= 13):
            errors.append(
                f"vocab {v['id']} bad system_id {v['system_id']}")
        for mid in v["morpheme_ids"]:
            if mid not in mid_domain:
                errors.append(
                    f"vocab {v['id']} references missing morpheme {mid}")
            elif mid_domain[mid] != v["domain"]:
                errors.append(
                    f"vocab {v['id']} ({v['domain']}) references "
                    f"morpheme {mid} ({mid_domain[mid]}): cross-domain leak")

    # Validate system_id range for articles
    for a in articles:
        if not (1 <= a["system_id"] <= 13):
            errors.append(
                f"article {a['id']} bad system_id {a['system_id']}")

    # Validate quiz questions
    vid_set = {v["id"] for v in vocab}
    mid_set = {m["id"] for m in morphemes}
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

    # ── Write ─────────────────────────────────────────────────────────────
    dump("morphemes.json", morphemes)
    dump("vocabulary.json", vocab)
    dump("knowledge.json", articles)
    dump("quiz_questions.json", quiz)

    # ── Summary ───────────────────────────────────────────────────────────
    macro_count = lambda rows, d: sum(1 for r in rows if r.get("domain") == d)
    print("OK")
    print(f"  morphemes: {len(morphemes)} "
          f"(macro: {macro_count(morphemes, 'macro')}, "
          f"micro: {macro_count(morphemes, 'micro')})")
    print(f"  vocabulary: {len(vocab)} "
          f"(macro: {macro_count(vocab, 'macro')}, "
          f"micro: {macro_count(vocab, 'micro')})")
    print(f"  articles: {len(articles)} "
          f"(macro: {macro_count(articles, 'macro')}, "
          f"micro: {macro_count(articles, 'micro')})")
    print(f"  quiz: {len(quiz)} "
          f"(macro: {macro_count(quiz, 'macro')}, "
          f"micro: {macro_count(quiz, 'micro')})")
    if warnings:
        print(f"  ({len(warnings)} morpheme-key warnings; "
              f"those links were skipped)")
        for w in warnings[:20]:
            print("    !", w)


if __name__ == "__main__":
    main()
