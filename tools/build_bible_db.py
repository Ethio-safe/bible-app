#!/usr/bin/env python3
"""
Builds the read-only Bible SQLite databases shipped in assets/bible/.

Sources (all public domain):
  KJV, ASV  -> scrollmapper/bible_databases (JSON)
  WEB       -> ebible.org (verse-per-line text, engwebp = Protestant canon)

Usage:
  python3 tools/build_bible_db.py            # builds kjv.db, web.db, asv.db
  python3 tools/build_bible_db.py kjv web    # subset

Output schema (identical for every translation):
  meta(key TEXT PRIMARY KEY, value TEXT)
  books(id INTEGER PRIMARY KEY, name TEXT, abbreviation TEXT, testament TEXT, chapter_count INTEGER)
  verses(id INTEGER PRIMARY KEY, book_id INTEGER, chapter INTEGER, verse INTEGER, text TEXT)
  verses_fts (FTS5 external-content table over verses.text)
"""
from __future__ import annotations

import io
import json
import os
import sqlite3
import sys
import urllib.request
import zipfile
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "assets" / "bible"
CACHE_DIR = Path(os.environ.get("BIBLE_CACHE", ROOT / ".cache" / "bible_sources"))
SCHEMA_VERSION = 1

SCROLLMAPPER = "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/json/{code}.json"
EBIBLE_WEB = "https://ebible.org/Scriptures/engwebp_vpl.zip"

# Canonical 66-book order with display name, short abbreviation, testament, and
# the ebible.org / USFM-style code used in the WEB source.
CANON: list[tuple[str, str, str, str]] = [
    ("Genesis", "Gen", "OT", "GEN"), ("Exodus", "Exod", "OT", "EXO"), ("Leviticus", "Lev", "OT", "LEV"),
    ("Numbers", "Num", "OT", "NUM"), ("Deuteronomy", "Deut", "OT", "DEU"), ("Joshua", "Josh", "OT", "JOS"),
    ("Judges", "Judg", "OT", "JDG"), ("Ruth", "Ruth", "OT", "RUT"), ("1 Samuel", "1Sam", "OT", "1SA"),
    ("2 Samuel", "2Sam", "OT", "2SA"), ("1 Kings", "1Kgs", "OT", "1KI"), ("2 Kings", "2Kgs", "OT", "2KI"),
    ("1 Chronicles", "1Chr", "OT", "1CH"), ("2 Chronicles", "2Chr", "OT", "2CH"), ("Ezra", "Ezra", "OT", "EZR"),
    ("Nehemiah", "Neh", "OT", "NEH"), ("Esther", "Esth", "OT", "EST"), ("Job", "Job", "OT", "JOB"),
    ("Psalms", "Ps", "OT", "PSA"), ("Proverbs", "Prov", "OT", "PRO"), ("Ecclesiastes", "Eccl", "OT", "ECC"),
    ("Song of Solomon", "Song", "OT", "SOL"), ("Isaiah", "Isa", "OT", "ISA"), ("Jeremiah", "Jer", "OT", "JER"),
    ("Lamentations", "Lam", "OT", "LAM"), ("Ezekiel", "Ezek", "OT", "EZE"), ("Daniel", "Dan", "OT", "DAN"),
    ("Hosea", "Hos", "OT", "HOS"), ("Joel", "Joel", "OT", "JOE"), ("Amos", "Amos", "OT", "AMO"),
    ("Obadiah", "Obad", "OT", "OBA"), ("Jonah", "Jonah", "OT", "JON"), ("Micah", "Mic", "OT", "MIC"),
    ("Nahum", "Nah", "OT", "NAH"), ("Habakkuk", "Hab", "OT", "HAB"), ("Zephaniah", "Zeph", "OT", "ZEP"),
    ("Haggai", "Hag", "OT", "HAG"), ("Zechariah", "Zech", "OT", "ZEC"), ("Malachi", "Mal", "OT", "MAL"),
    ("Matthew", "Matt", "NT", "MAT"), ("Mark", "Mark", "NT", "MAR"), ("Luke", "Luke", "NT", "LUK"),
    ("John", "John", "NT", "JOH"), ("Acts", "Acts", "NT", "ACT"), ("Romans", "Rom", "NT", "ROM"),
    ("1 Corinthians", "1Cor", "NT", "1CO"), ("2 Corinthians", "2Cor", "NT", "2CO"), ("Galatians", "Gal", "NT", "GAL"),
    ("Ephesians", "Eph", "NT", "EPH"), ("Philippians", "Phil", "NT", "PHI"), ("Colossians", "Col", "NT", "COL"),
    ("1 Thessalonians", "1Thess", "NT", "1TH"), ("2 Thessalonians", "2Thess", "NT", "2TH"), ("1 Timothy", "1Tim", "NT", "1TI"),
    ("2 Timothy", "2Tim", "NT", "2TI"), ("Titus", "Titus", "NT", "TIT"), ("Philemon", "Phlm", "NT", "PHM"),
    ("Hebrews", "Heb", "NT", "HEB"), ("James", "Jas", "NT", "JAM"), ("1 Peter", "1Pet", "NT", "1PE"),
    ("2 Peter", "2Pet", "NT", "2PE"), ("1 John", "1John", "NT", "1JO"), ("2 John", "2John", "NT", "2JO"),
    ("3 John", "3John", "NT", "3JO"), ("Jude", "Jude", "NT", "JUD"), ("Revelation", "Rev", "NT", "REV"),
]
CODE_TO_INDEX = {c[3]: i for i, c in enumerate(CANON)}


@dataclass
class TranslationSpec:
    key: str            # file name (kjv -> kjv.db)
    abbreviation: str
    name: str
    language: str
    license: str
    source: str
    loader: str         # "scrollmapper" | "ebible_vpl"


SPECS = {
    "kjv": TranslationSpec("kjv", "KJV", "King James Version (1769)", "en",
                           "Public Domain", "scrollmapper/bible_databases (KJV)", "scrollmapper"),
    "web": TranslationSpec("web", "WEB", "World English Bible", "en",
                           "Public Domain", "ebible.org (engwebp)", "ebible_vpl"),
    "asv": TranslationSpec("asv", "ASV", "American Standard Version (1901)", "en",
                           "Public Domain", "scrollmapper/bible_databases (ASV)", "scrollmapper"),
}

# verses[book_index][chapter][verse] = text
Verses = dict[int, dict[int, dict[int, str]]]


def fetch(url: str, cache_name: str) -> bytes:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    cached = CACHE_DIR / cache_name
    if cached.exists():
        return cached.read_bytes()
    print(f"  downloading {url}")
    with urllib.request.urlopen(url, timeout=120) as r:
        data = r.read()
    cached.write_bytes(data)
    return data


def load_scrollmapper(code: str) -> Verses:
    data = json.loads(fetch(SCROLLMAPPER.format(code=code), f"{code}.json"))
    books = data["books"]
    if len(books) != 66:
        raise SystemExit(f"{code}: expected 66 books, got {len(books)}")
    out: Verses = {}
    for idx, book in enumerate(books):  # source is already in canonical order
        chapters: dict[int, dict[int, str]] = {}
        for ch in book["chapters"]:
            chapters[int(ch["chapter"])] = {
                int(v["verse"]): clean(v["text"]) for v in ch["verses"]
            }
        out[idx] = chapters
    return out


def load_ebible_vpl(url: str) -> Verses:
    zdata = fetch(url, "engwebp_vpl.zip")
    with zipfile.ZipFile(io.BytesIO(zdata)) as z:
        name = next(n for n in z.namelist() if n.endswith("_vpl.txt"))
        text = z.read(name).decode("utf-8")
    out: Verses = {}
    for line in text.splitlines():
        if not line.strip():
            continue
        code, rest = line.split(" ", 1)
        ref, verse_text = rest.split(" ", 1)
        if code not in CODE_TO_INDEX:
            continue  # skip anything outside the 66-book canon
        ch_s, v_s = ref.split(":")
        idx = CODE_TO_INDEX[code]
        out.setdefault(idx, {}).setdefault(int(ch_s), {})[int(v_s)] = clean(verse_text)
    if len(out) != 66:
        raise SystemExit(f"WEB: expected 66 books, got {len(out)}")
    return out


def clean(s: str) -> str:
    return " ".join(s.replace("\u00a0", " ").split())


def build_db(spec: TranslationSpec, verses: Verses, path: Path) -> None:
    if path.exists():
        path.unlink()
    con = sqlite3.connect(path)
    cur = con.cursor()
    cur.executescript(
        """
        PRAGMA page_size = 4096;
        CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
        CREATE TABLE books (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            abbreviation TEXT NOT NULL,
            testament TEXT NOT NULL CHECK (testament IN ('OT','NT')),
            chapter_count INTEGER NOT NULL
        );
        CREATE TABLE verses (
            id INTEGER PRIMARY KEY,
            book_id INTEGER NOT NULL REFERENCES books(id),
            chapter INTEGER NOT NULL,
            verse INTEGER NOT NULL,
            text TEXT NOT NULL
        );
        CREATE UNIQUE INDEX idx_verses_ref ON verses(book_id, chapter, verse);
        CREATE VIRTUAL TABLE verses_fts USING fts5(
            text,
            content='verses',
            content_rowid='id',
            tokenize='porter unicode61 remove_diacritics 2'
        );
        """
    )
    cur.executemany(
        "INSERT INTO meta(key, value) VALUES (?, ?)",
        [
            ("schema_version", str(SCHEMA_VERSION)),
            ("abbreviation", spec.abbreviation),
            ("name", spec.name),
            ("language", spec.language),
            ("license", spec.license),
            ("source", spec.source),
        ],
    )

    verse_rows: list[tuple[int, int, int, int, str]] = []
    vid = 0
    for idx, (name, abbr, testament, _code) in enumerate(CANON):
        chapters = verses[idx]
        cur.execute(
            "INSERT INTO books(id, name, abbreviation, testament, chapter_count) VALUES (?,?,?,?,?)",
            (idx + 1, name, abbr, testament, max(chapters)),
        )
        for ch in sorted(chapters):
            for v in sorted(chapters[ch]):
                vid += 1
                verse_rows.append((vid, idx + 1, ch, v, chapters[ch][v]))
    cur.executemany("INSERT INTO verses VALUES (?,?,?,?,?)", verse_rows)
    cur.execute("INSERT INTO verses_fts(verses_fts) VALUES ('rebuild')")
    cur.execute("INSERT INTO verses_fts(verses_fts) VALUES ('optimize')")
    con.commit()
    cur.execute("VACUUM")
    con.close()
    print(f"  {path.name}: {len(verse_rows)} verses, {path.stat().st_size / 1_048_576:.1f} MB")


def main(argv: list[str]) -> None:
    keys = [a.lower() for a in argv] or list(SPECS)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for key in keys:
        spec = SPECS[key]
        print(f"Building {spec.abbreviation} …")
        if spec.loader == "scrollmapper":
            verses = load_scrollmapper(spec.abbreviation)
        else:
            verses = load_ebible_vpl(EBIBLE_WEB)
        build_db(spec, verses, OUT_DIR / f"{key}.db")
    print("Done.")


if __name__ == "__main__":
    main(sys.argv[1:])
