"""Read-only importer for an English Ethiopian 81-book study collection.

Mixed translations, uncollated: NOT an authoritative Ethiopian 81-book canon,
critical edition, or a verified complete verse-level text. No translation or
missing words are supplied here. In particular, damaged superscripts cannot be
reconstructed by guessing. Consumers MUST retain/display the metadata: source
chapter notes contain scripture fragments and Greek Esther additions, not just
commentary. A verses-only database is not a complete rendering of this source.

Usage: ``books, metadata = load_english(build_bible_db.fetch)``. The callable
accepts (url, cache_name) and returns bytes. No network or filesystem activity
occurs on import. Only JSON members are read from the tar; nothing is extracted
or executed. All metadata values are strings; structured values are JSON.

source_id values are stable textual codes, not app IDs or catalog positions.
The parent builder must map them explicitly. SOURCE_CODES / metadata key_mapping
give the actual archive-slug mapping. DAG retains chapters 3, 13, 14; 4EZ retains
source chapters 1-12 (the apocalyptic core conventionally 2 Esdras 3-14).
Meqabyan is not Greek Maccabees. BAR includes the Letter in chapter 6; PSA
includes Psalm 151. These packaging choices do not define a church's canon.
"""

from __future__ import annotations

import base64
import gzip
import hashlib
import io
import json
import re
import tarfile
from collections import Counter
from collections.abc import Callable

# Resolved using GitHub /repos/gmrod87/modern-ethiopian-bible-81/commits/HEAD.
SOURCE_COMMIT = "299e7cc38fff7cfdb4565dda3ff0a09bf9c6b3c0"
SOURCE_SHA256 = "426fb82de470a85e0aeacfd56734ca5460228b408664b263dff4d4f19cae834f"
SOURCE_URL = (
    "https://raw.githubusercontent.com/gmrod87/modern-ethiopian-bible-81/"
    f"{SOURCE_COMMIT}/native-bible-app.tar.gz"
)
CACHE_NAME = f"ethiopian-english-{SOURCE_COMMIT}.tar.gz"
COLLECTION_NAME = "English Ethiopian 81-book study collection (mixed translations, uncollated)"

# Explicit codes intentionally independent of source order and canonical app IDs.
SOURCE_CODES = dict(pair.split("=") for pair in """
genesis=GEN exodus=EXO leviticus=LEV numbers=NUM deuteronomy=DEU
joshua=JOS judges=JDG ruth=RUT 1-samuel=1SA 2-samuel=2SA
1-kings=1KI 2-kings=2KI 1-chronicles=1CH 2-chronicles=2CH
ezra=EZR nehemiah=NEH esther=EST job=JOB psalms=PSA proverbs=PRO
ecclesiastes=ECC song-of-songs=SOL isaiah=ISA jeremiah=JER lamentations=LAM
ezekiel=EZE daniel=DAN hosea=HOS joel=JOE amos=AMO obadiah=OBA
jonah=JON micah=MIC nahum=NAH habakkuk=HAB zephaniah=ZEP haggai=HAG
zechariah=ZEC malachi=MAL matthew=MAT mark=MAR luke=LUK john=JOH
acts=ACT romans=ROM 1-corinthians=1CO 2-corinthians=2CO galatians=GAL
ephesians=EPH philippians=PHI colossians=COL 1-thessalonians=1TH
2-thessalonians=2TH 1-timothy=1TI 2-timothy=2TI titus=TIT philemon=PHM
hebrews=HEB james=JAM 1-peter=1PE 2-peter=2PE 1-john=1JO
2-john=2JO 3-john=3JO jude=JUD revelation=REV jubilees=JUB 1-enoch=ENO
2-ezra-1-esdras=1ES ezra-sutuel-4-ezra-apocalyptic-core=4EZ
tobit=TOB judith=JDT 1-meqabyan=1MQ 2-meqabyan=2MQ 3-meqabyan=3MQ
wisdom-of-solomon=WIS sirach-ecclesiasticus=SIR
baruch-and-letter-of-jeremiah=BAR 4-baruch-paralipomena-of-jeremiah=4BA
prayer-of-manasseh=MAN daniel-greek-additions=DAG
""".split())

DAMAGED_CODES = {"JUB", "ENO", "1MQ", "2MQ", "3MQ", "4BA"}
SUPERSCRIPTS = "⁰¹²³⁴⁵⁶⁷⁸⁹"
SUPER_DIGITS = str.maketrans(SUPERSCRIPTS, "0123456789")
MARKERS = re.compile(r"(?<!\S)([⁰¹²³⁴⁵⁶⁷⁸⁹]+)(?=\s)")
WEB_FOOTER = re.compile(
    r"(?:xxiv The World English Bible The World English Bible|English Bible) "
    r"is in the Public Domain\. That means that it is not copyrighted\."
    r".*?PDF generated using Haiola and XeLaTeX .*?"
    r"9b352775-05c1-564e-85c2-0b15c0ea73b9"
)
DANIEL_PAGE = re.compile(r"Daniel \(Greek\) \d+:\d+ \d+ Daniel \(Greek\) \d+:\d+")


def _clean(text: str) -> str:
    if not isinstance(text, str):
        raise ValueError("Expected source text to be a string")
    # Do not use NFKC: it destroys the distinction between superscripts and prose.
    return " ".join(text.split())


def _split_markers(number: int, text: str, next_number: int | None) -> dict[int, str]:
    """Split only a complete superscript run anchored at BOTH explicit ends.

    ASCII numbers can be dates, quantities, references or page numbers. Never
    split them. Truncated superscripts (e.g. ¹ standing for 10 or 14) fail the
    consecutive-run check. An unanchored final record is also left untouched.
    This intentionally does not repair the known collapsed chapter-ending rows.
    """
    matches = list(MARKERS.finditer(text))
    if not matches or next_number is None or next_number <= number + 1:
        return {number: text}
    numbers = [int(m[1].translate(SUPER_DIGITS)) for m in matches]
    if numbers != list(range(number + 1, next_number)):
        return {number: text}
    parts = [text[:matches[0].start()]] + [
        text[m.end():matches[i + 1].start() if i + 1 < len(matches) else len(text)]
        for i, m in enumerate(matches)
    ]
    parts = [_clean(p) for p in parts]
    if not all(parts):
        return {number: text}
    return dict(zip([number] + numbers, parts))


def _remove_metadata(text: str, code: str, title: str, ref: str,
                     audit: list[dict]) -> str:
    """Remove only observed, recognizable print metadata; retain an audit copy."""
    patterns = [WEB_FOOTER]
    if code == "PRO":
        patterns.append(re.compile(r"lxxiv The World English Bible The World$"))
    if code == "DAG":
        patterns.append(DANIEL_PAGE)
    if code in DAMAGED_CODES:
        # These exact repeated running titles interrupt prose in the pinned PDF
        # conversion. Do not generalize to arbitrary biblical references.
        patterns.append(re.compile(r"(?<!\S)" + re.escape(title) + r" \d+(?![\d:])\b"))
    original = text
    removed = []
    for pattern in patterns:
        def replace(match: re.Match) -> str:
            removed.append(match.group())
            return " "
        text = pattern.sub(replace, text)
    text = _clean(text)
    if removed:
        if not text:
            # Never silently erase a nonempty source record.
            text = original
        audit.append({"kind": "print_metadata", "ref": ref,
                      "original": original, "removed": removed,
                      "applied": text != original})
    return text


def _read_archive(data: bytes) -> tuple[list[dict], dict[str, dict]]:
    if hashlib.sha256(data).hexdigest() != SOURCE_SHA256:
        raise ValueError("Source SHA256 mismatch; refusing unreviewed or corrupt archive")
    wanted = {"./books.json", "./ot.b64", "./nt.b64", "./eth.b64"}
    members = {}
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as archive:
        for member in archive:
            if member.name not in wanted:
                continue
            if not member.isfile() or member.name in members or member.size > 20_000_000:
                raise ValueError(f"Invalid archive member: {member.name}")
            stream = archive.extractfile(member)  # read bytes, never extract to disk
            if stream is None:
                raise ValueError(f"Unreadable member: {member.name}")
            members[member.name] = stream.read()
    if set(members) != wanted:
        raise ValueError("Missing catalog or encoded JSON payload")
    catalog = json.loads(members["./books.json"])
    payload = {}
    for part in ("ot", "nt", "eth"):
        compressed = base64.b64decode(members[f"./{part}.b64"], validate=True)
        decoded = json.loads(gzip.decompress(compressed))
        if payload.keys() & decoded.keys():
            raise ValueError("Duplicate book keys across payloads")
        payload.update(decoded)
    return catalog, payload


def _positive(value: object) -> int:
    if type(value) is not int or value < 1:
        raise ValueError(f"Invalid source chapter/verse number: {value!r}")
    return value


def _convert(catalog: list[dict], payload: dict[str, dict]) -> tuple[list[dict], dict[str, str]]:
    slugs = [entry["slug"] for entry in catalog]
    if len(slugs) != 81 or len(set(slugs)) != 81 or set(slugs) != set(SOURCE_CODES):
        raise ValueError("Catalog does not match the reviewed 81 source keys")
    if set(payload) != set(slugs):
        raise ValueError("Catalog/payload book mismatch")
    books, audit, defects, inventory = [], [], [], []
    extra = {}
    for entry in catalog:
        slug = entry["slug"]
        source = payload[slug]
        code = SOURCE_CODES[slug]
        if any(source[k] != entry[k] for k in ("slug", "title", "category")):
            raise ValueError(f"Catalog/payload identity mismatch: {slug}")
        if source["category"] not in {"ot", "eth", "nt"}:
            raise ValueError(f"Unknown category: {slug}")
        chapters = {}
        book_extra = {k: v for k, v in source.items() if k != "chapters"}
        book_extra["chapters"] = {}
        expected_chapters = {c["n"]: c for c in entry["chapters"]}
        if len(expected_chapters) != len(entry["chapters"]):
            raise ValueError(f"Duplicate catalog chapters: {slug}")
        for chapter in source["chapters"]:
            ch = _positive(chapter["n"])
            ref = f"{code} {ch}"
            if ch in chapters or ch not in expected_chapters:
                raise ValueError(f"Unexpected/duplicate chapter: {ref}")
            # Keep original notes/labels/sections verbatim, plus a cleaned note.
            details = {k: v for k, v in chapter.items() if k != "verses"}
            details["cleaned_note"] = _remove_metadata(
                _clean(chapter.get("note", "")), code, source["title"], ref + " note", audit)
            book_extra["chapters"][ch] = details
            rows = chapter["verses"]
            if len(rows) != expected_chapters[ch]["verses"]:
                defects.append({"kind": "catalog_row_count", "ref": ref,
                                "catalog": expected_chapters[ch]["verses"], "actual": len(rows)})
            verses = {}
            nums = [_positive(row["v"]) for row in rows]
            for index, row in enumerate(rows):
                num = nums[index]
                vref = f"{ref}:{num}"
                text = _clean(row["t"])
                if not text:
                    defects.append({"kind": "empty_source_row", "ref": vref})
                    continue
                text = _remove_metadata(text, code, source["title"], vref, audit)
                next_num = nums[index + 1] if index + 1 < len(nums) else None
                parts = _split_markers(num, text, next_num) if code in DAMAGED_CODES else {num: text}
                if len(parts) > 1:
                    audit.append({"kind": "split_markers", "ref": vref,
                                  "original": row, "numbers": list(parts)})
                elif MARKERS.search(text):
                    defects.append({"kind": "unresolved_markers", "ref": vref})
                for n, part in parts.items():
                    if n in verses:
                        defects.append({"kind": "duplicate_reference", "ref": f"{ref}:{n}",
                                        "policy": "concatenate in source order; not a verified verse"})
                        verses[n] += " " + part
                    else:
                        verses[n] = part
                if len(text) > 2000:
                    defects.append({"kind": "long_source_row", "ref": vref, "characters": len(text)})
            if len(nums) != len(set(nums)) or any(set(r) != {"v", "t"} for r in rows):
                details["original_verse_records"] = rows
            missing = sorted(set(range(1, max(verses, default=0) + 1)) - verses.keys())
            if missing:
                defects.append({"kind": "verse_number_gaps", "ref": ref, "numbers": missing})
            if not verses:
                defects.append({"kind": "empty_chapter", "ref": ref})
            chapters[ch] = dict(sorted(verses.items()))
        if set(chapters) != set(expected_chapters):
            raise ValueError(f"Missing payload chapters: {slug}")
        gaps = sorted(set(range(1, max(chapters) + 1)) - chapters.keys())
        if gaps:
            defects.append({"kind": "chapter_number_gaps", "ref": code, "numbers": gaps,
                            "intentional_packaging": code == "DAG"})
        extra[code] = book_extra
        books.append({"source_id": code, "name": source["title"], "abbreviation": code,
                      "testament": "NT" if source["category"] == "nt" else "OT",
                      "chapters": dict(sorted(chapters.items()))})
        inventory.append({"source_id": code, "slug": slug, "name": source["title"],
                          "chapters": list(chapters), "chapter_count": len(chapters),
                          "verse_records": sum(len(c) for c in chapters.values())})
    quality = {
        "status": "mixed translations, uncollated; unsuitable as an authoritative verse-level edition",
        "counts": {
            "books": len(books), "chapters": sum(len(b["chapters"]) for b in books),
            "output_verse_records": sum(len(c) for b in books for c in b["chapters"].values()),
            "defects_by_kind": dict(Counter(d["kind"] for d in defects)),
            "cleanup_by_kind": dict(Counter(d["kind"] for d in audit)),
            "marker_splits": sum(d["kind"] == "split_markers" for d in audit),
        },
        "limitations": [
            "81 catalog entries = standard 66 plus 15; not a verified Ethiopian church canon.",
            "No broader-canon Sinodos, Books of the Covenant, Ethiopic Clement or Ethiopic Didascalia entries.",
            "The pinned source has no verse rows for Ecclesiastes 5. Its note is preserved; no replacement chapter is supplied.",
            "Source labels include apparent parsing artifacts (PSA 147:146, JUB 4:930, ENO 74:364) and Greek-addition rows inside EST 10. They are retained, not certified as valid references.",
            "Jubilees, Enoch, Meqabyan and 4 Baruch have collapsed verses and truncated superscripts. Missing boundaries/words are not inferred.",
            "Duplicate verse labels are concatenated without losing text; originals are retained. The resulting labels are not verified verse boundaries.",
            "Number gaps are observed within source ranges, not proof of missing scripture; absent final verses cannot be detected without collation.",
            "Notes mix commentary, headings, verse continuations and scripture. Greek Esther additions and Greek Proverbs apparatus remain in source_structure, not invented verse rows.",
            "PSA includes 151; numbering is not uniformly Ethiopic. DAG keeps expanded Daniel 3, Susanna 13, Bel 14 (overlaps DAN). BAR includes Letter chapter 6.",
            "4EZ has 12 locally numbered chapters of the apocalyptic core, not the full 16-chapter 2 Esdras. Meqabyan is not Greek Maccabees.",
            "English style and translation provenance vary; no modernization or translation correction performed. Rights for the whole compilation have not been verified.",
            "Only recognizable print contamination is removed, with originals in cleanup_audit; other OCR, transcription, note placement and textual defects may remain.",
        ],
        "defects": defects,
    }
    dump = lambda value: json.dumps(value, ensure_ascii=False, separators=(",", ":"))
    return books, {
        "name": COLLECTION_NAME, "language": "en", "source": SOURCE_URL,
        "source_commit": SOURCE_COMMIT, "source_sha256": SOURCE_SHA256,
        "license": "Mixed source compilation; per-text rights not independently verified",
        "key_mapping": dump(SOURCE_CODES), "inventory": dump(inventory),
        "source_catalog": dump(catalog), "source_structure": dump(extra),
        "cleanup_audit": dump(audit), "quality_notes": dump(quality),
    }


def load_english(fetch: Callable[[str, str], bytes]) -> tuple[list[dict], dict[str, str]]:
    """Fetch a hash-pinned archive and return books plus loss-aware metadata.

    Raises ValueError for hash, identity or structural inconsistencies rather
    than silently dropping books. The injected fetcher controls caching/network.
    No app IDs are assigned; chapter and verse numbers are source-local.
    """
    catalog, payload = _read_archive(fetch(SOURCE_URL, CACHE_NAME))
    return _convert(catalog, payload)