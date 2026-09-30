#!/usr/bin/env python3
"""Build two offline educational collections; never claim verified completeness.

Run with no arguments for both, or eot_am / eot_en. Source files are cached,
hash-pinned where available, and never executed. Existing KJV/WEB/ASV assets
are untouched. Edition-local IDs deliberately prevent cross-versification
bookmark collisions. Extra source material and transformation audits remain
in the database; human-readable chapter notices are displayed by the reader.
"""
from __future__ import annotations

import hashlib
import json
import sqlite3
import sys
from pathlib import Path

from build_bible_db import CANON, OUT_DIR, fetch, load_ebible_vpl, EBIBLE_WEB
from ethiopian_english import load_english, DAMAGED_CODES
from ethiopian_english_components import load_components

AM_COMMIT = '0474b76b8c9e50c6ee25f729c7fc9a56a133e366'
AM_URL = f'https://raw.githubusercontent.com/bogaledemasrepo/RN-Bible/{AM_COMMIT}/assets/bible.db'
AM_HASH = 'eeec8c90bf7f3849c8d05d7ab1edff910e82a6a59ce73c74fe31dfb6abfefff3'
CANON_NAMES = {name: i + 1 for i, (name, _, _, _) in enumerate(CANON)}
CANON_CODES = {code: i + 1 for i, (_, _, _, code) in enumerate(CANON)}


def dump(value):
    return json.dumps(value, ensure_ascii=False, separators=(',', ':'))


def load_amharic():
    raw = fetch(AM_URL, 'amharic-0474b76.db')
    if hashlib.sha256(raw).hexdigest() != AM_HASH:
        raise ValueError('Amharic source hash mismatch')
    db = sqlite3.connect(':memory:')
    db.deserialize(raw)
    db.execute('PRAGMA query_only=ON')
    if db.execute('PRAGMA integrity_check').fetchone()[0] != 'ok':
        raise ValueError('Invalid source database')
    books, mapping, notes, passages, sections = [], {}, {}, [], []
    for bid, name, abbr, english, _, testament in db.execute('SELECT * FROM books ORDER BY book_id'):
        app_id = 1000 + bid
        if english in CANON_NAMES:
            mapping[str(CANON_NAMES[english])] = app_id
        chapters = {}
        duplicate_chapters = set()
        for ch, section, num, text, title in db.execute('''
            SELECT c.chapter_number,c.chapter_id,v.verse_number,v.verse_text,c.section_title
            FROM chapters c JOIN verses v USING(chapter_id)
            WHERE c.book_id=? ORDER BY c.chapter_number,c.chapter_id,v.verse_id
        ''', (bid,)):
            if not text.strip() or num < 1 or ch < 1:
                raise ValueError(f'Invalid Amharic record {bid}:{ch}:{num}')
            verses = chapters.setdefault(ch, {})
            if num in verses:
                duplicate_chapters.add(ch)
            # Keep a lossless, ordered source record for audit and repeated labels.
            sections.append([app_id, ch, section, num, text, title])
            verses[num] = verses.get(num, '') + ('\n\n' if num in verses else '') + text
        for ch in duplicate_chapters:
            rows = [r for r in sections if r[0] == app_id and r[1] == ch]
            chapters[ch] = {1: '\n\n'.join(f'{r[3]}  {r[4]}' for r in rows)}
            passages.append(f'{app_id}:{ch}')
            notes[f'{app_id}:{ch}'] = (
                'Source sections repeat verse labels. This chapter is shown as one reading passage '
                'in original section order; embedded numbers are source labels, not app verse references.')
        books.append(dict(id=app_id, name=name, abbreviation=abbr, testament='NT' if testament == 'new' else 'OT', chapters=chapters))
    db.close()
    if len(books) != 81:
        raise ValueError('Expected 81 Amharic books')
    return books, {
        'name': 'Ethiopian Orthodox — አማርኛ (81-book study edition)',
        'abbreviation': 'EOT-AM', 'language': 'am', 'source': AM_URL, 'source_url': AM_URL,
        'source_commit': AM_COMMIT, 'source_sha256': AM_HASH,
        'license': 'Upstream transcription; underlying translation rights not independently verified',
        'quality_notes': '81-book Amharic collection (54 OT + 27 NT), including Ethiopian Meqabyan, Henok and Kufale. '
            'Not independently collated against a named printed edition. Source numbering and combined verses are preserved; '
            'Psalm 9 repeats verse labels and is shown as a chapter passage. Psalm 151 is included. '
            'Ezra Sutuel needs editorial review. This is not the broader collection of all Sinodos and Covenant works. '
            'Chapter and verse divisions differ from English editions; references are kept separate.',
        'canonical_book_ids': dump(mapping), 'chapter_notes': dump(notes),
        'passage_chapters': dump(passages), 'original_sections': dump(sections),
    }


def load_english_study():
    source_books, original_meta = load_english(fetch)
    components, component_meta = load_components(fetch)
    # Replace the archive's damaged standard-book PDF extraction with the clean,
    # separately attributed WEB text already used by the app. No invented verses.
    web = load_ebible_vpl(EBIBLE_WEB)
    web_bytes = fetch(EBIBLE_WEB, 'engwebp_vpl.zip')
    structure = json.loads(original_meta['source_structure'])
    books, mapping, notes, passages = [], {}, {}, []
    for index, source in enumerate(source_books, 1):
        code, app_id = source['source_id'], 2000 + index
        chapters = source['chapters']
        chapter_notes = {}
        if code in CANON_CODES:
            canonical = CANON_CODES[code]
            mapping[str(canonical)] = app_id
            chapters = {
                c: {n: text for n, text in vs.items() if text.strip()}
                for c, vs in web[canonical - 1].items()
            }
            # Preserve Psalm 151 as explicitly sourced supplementary text.
            if code == 'PSA' and 151 in source['chapters']:
                chapters[151] = source['chapters'][151]
                chapter_notes[151] = 'Supplement: Psalm 151 from the mixed-source archive, not the Protestant WEB.'
            if code == 'EST':
                addition = structure[code]['chapters']['10'].get('cleaned_note', '')
                if addition:
                    chapter_notes[10] = 'Archive supplementary material (source placement, not WEB verse numbering):\n\n' + addition
        elif code in DAMAGED_CODES:
            # Missing verse boundaries cannot be reliably reconstructed. Keep all
            # surviving prose as a chapter passage instead of fake verse 930 etc.
            rebuilt = {}
            for ch, vs in chapters.items():
                if ch in components.get(code, {}):
                    rebuilt[ch] = components[code][ch]
                    chapter_notes[ch] = 'Meqabyan: AI-assisted English draft translated from Amharic (May 2026), unreviewed and not collated against Geʽez. Source-numbered verses; accuracy is not certified.'
                else:
                    note = structure[code]['chapters'][str(ch)].get('cleaned_note', '')
                    rebuilt[ch] = {1: '\n\n'.join(filter(None, [note, *vs.values()]))}
                    passages.append(f'{app_id}:{ch}')
                    chapter_notes[ch] = 'Uncollated archive text. Verse boundaries are damaged, so this is a whole-chapter reading passage, not verse 1. Embedded numbers may be OCR artifacts.'
                    if code == '1MQ':
                        chapter_notes[ch] += ' The newer Meqabyan draft omits chapter 1; this chapter retains the older archive wording, which differs markedly in style.'
            chapters = rebuilt
        elif code == 'DAG':
            # App chapter paging is sequential; preserve original numbering in
            # labels and notes instead of exposing eleven empty chapter pages.
            chapters = {i: vs for i, (_, vs) in enumerate(source['chapters'].items(), 1)}
            for i, original in enumerate(source['chapters'], 1):
                chapter_notes[i] = f'Supplement {i}: source Greek Daniel chapter {original}. Supplement numbers 1–3 are local reading sections, not standard Daniel chapters.'
            source = {**source, 'name': 'Daniel Greek Additions (3 sections)'}
        else:
            for ch in chapters:
                note = structure[code]['chapters'][str(ch)].get('cleaned_note', '')
                if note:
                    chapter_notes[ch] = 'Additional source material:\n\n' + note
        for ch, text in chapter_notes.items():
            notes[f'{app_id}:{ch}'] = text
        books.append(dict(id=app_id, name=source['name'], abbreviation=source['abbreviation'], testament=source['testament'], chapters=chapters))
    quality = (
        'Educational 81-entry English study collection, NOT a verified complete or church-approved Ethiopian translation. '
        'The standard 66 books use the World English Bible; 15 additional entries come from a mixed-source archive. '
        'These entries do not match the Amharic book grouping exactly. Broader-canon church-order books are not included. '
        'Enoch, Jubilees, 4 Baruch and 1 Meqabyan chapter 1 are chapter passages because source verse boundaries are damaged. '
        'Other Meqabyan chapters use an AI-assisted, single-witness, unreviewed May 2026 draft; 1 Meqabyan chapter 1 is absent from that draft and retains older archive wording. '
        'Greek Daniel additions use three local sections, with original chapter labels in the reader notes. '
        'Source notes and original extraction audits are preserved. Textual completeness and accuracy remain unverified.'
    )
    meta = {f'archive_{k}': v for k, v in original_meta.items()}
    meta.update({f'meqabyan_{k}': v for k, v in component_meta.items()})
    meta.update({
        'name': 'Ethiopian — English (81-entry study collection)', 'abbreviation': 'EOT-EN', 'language': 'en',
        'source': original_meta['source'], 'source_url': original_meta['source'],
        'license': original_meta['license'] + '; WEB public domain; Meqabyan draft CC0',
        'quality_notes': quality, 'canonical_book_ids': dump(mapping),
        'chapter_notes': dump(notes), 'passage_chapters': dump(passages),
        'web_source': EBIBLE_WEB, 'web_sha256': hashlib.sha256(web_bytes).hexdigest(),
    })
    return books, meta


def write_database(path: Path, books: list[dict], meta: dict[str, str]):
    if len(books) != 81 or len({b['id'] for b in books}) != 81:
        raise ValueError('Expected 81 unique book entries')
    # Build separately, validate, then atomically replace the prior good asset.
    temporary = path.with_suffix('.db.tmp')
    temporary.unlink(missing_ok=True)
    db = sqlite3.connect(temporary)
    try:
        db.executescript('''
            PRAGMA foreign_keys=ON;
            CREATE TABLE meta(key TEXT PRIMARY KEY,value TEXT NOT NULL);
            CREATE TABLE books(id INTEGER PRIMARY KEY,name TEXT NOT NULL,abbreviation TEXT NOT NULL,
                testament TEXT NOT NULL CHECK(testament IN ('OT','NT')),chapter_count INTEGER NOT NULL);
            CREATE TABLE verses(id INTEGER PRIMARY KEY,book_id INTEGER NOT NULL REFERENCES books(id),
                chapter INTEGER NOT NULL,verse INTEGER NOT NULL,text TEXT NOT NULL);
            CREATE UNIQUE INDEX idx_verses_ref ON verses(book_id,chapter,verse);
            CREATE VIRTUAL TABLE verses_fts USING fts5(text,content='verses',content_rowid='id',tokenize='unicode61');
        ''')
        meta = {**meta, 'schema_version': '1', 'book_count': '81', 'edition_kind': 'educational_study'}
        db.executemany('INSERT INTO meta VALUES (?,?)', meta.items())
        for book in books:
            chapters = book['chapters']
            if set(chapters) != set(range(1, max(chapters) + 1)):
                raise ValueError(f'Nonsequential chapters: {book["name"]}')
            db.execute('INSERT INTO books VALUES (?,?,?,?,?)', (book['id'],book['name'],book['abbreviation'],book['testament'],len(chapters)))
            for ch, verses in sorted(chapters.items()):
                if not verses or any(n < 1 or not t.strip() for n, t in verses.items()):
                    raise ValueError(f'Empty/invalid reading text: {book["name"]} {ch}')
                db.executemany('INSERT INTO verses(book_id,chapter,verse,text) VALUES (?,?,?,?)',
                    [(book['id'],ch,n,t) for n,t in sorted(verses.items())])
        db.execute("INSERT INTO verses_fts(verses_fts) VALUES('rebuild')")
        db.execute("INSERT INTO verses_fts(verses_fts) VALUES('integrity-check')")
        if db.execute('PRAGMA integrity_check').fetchone()[0] != 'ok' or db.execute('PRAGMA foreign_key_check').fetchall():
            raise ValueError('Database integrity failed')
        count = db.execute('SELECT count(*) FROM verses').fetchone()[0]
        db.commit()
        db.execute('VACUUM')
    finally:
        db.close()
    temporary.replace(path)
    print(f'{path.name}: 81 books; {count:,} reading records; {path.stat().st_size / 1048576:.1f} MiB')


def main(args):
    loaders = {'eot_am': load_amharic, 'eot_en': load_english_study}
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for key in args or loaders:
        if key not in loaders:
            raise SystemExit(f'Unknown edition: {key}')
        books, meta = loaders[key]()
        write_database(OUT_DIR / f'{key}.db', books, meta)


if __name__ == '__main__':
    main(sys.argv[1:])