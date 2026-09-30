"""Offline regression tests; opt-in actual-source test: ETHIOPIAN_COMPONENTS_LIVE=1."""

import hashlib
import io
import json
import os
import unittest
import urllib.request
import zipfile
from unittest.mock import patch

try:
    from . import ethiopian_english_components as source
except ImportError:
    import ethiopian_english_components as source


def chapter(body):
    return source._xml((f'<section xmlns="{source.NS["h"]}"><h2>Chapter 1</h2>{body}</section>').encode())


def fixture():
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w") as archive:
        archive.writestr("mimetype", "application/epub+zip")
        for code, (member, title) in source.BOOK_MEMBERS.items():
            chapters = ''.join(
                f'<section><h2>Chapter {n}</h2><p><strong>1</strong> First <em>words</em>.</p>'
                '<blockquote><p>Note on the reading.</p></blockquote></section>'
                for n in range(2 if code == "1MQ" else 1, source.EXPECTED_CHAPTERS[code] + 1))
            archive.writestr(member, f'<html xmlns="{source.NS["h"]}"><body><h1>{title}</h1>{chapters}</body></html>')
    return buffer.getvalue()


class ComponentTests(unittest.TestCase):
    def test_explicit_markers_and_inline_text(self):
        verses, notes, passage = source._chapter(chapter(
            '<p>Introduction remains a note.</p>'
            '<p><strong>1</strong> First <em>whole</em> sentence &amp; tail.</p>'
            '<blockquote><p><strong>2</strong> Not a verse.</p></blockquote>'
            '<p><strong>2</strong> Second: 364 days, ¹ broken superscript.</p>'
            '<table><tr><td><p><strong>3</strong> Confidence.</p></td></tr></table>'))
        self.assertFalse(passage)
        self.assertEqual(verses, {1: 'First whole sentence & tail.', 2: 'Second: 364 days, ¹ broken superscript.'})
        self.assertIn('Introduction remains', notes)
        self.assertIn('Not a verse', notes)
        self.assertIn('Confidence', notes)
        self.assertNotIn('whole', notes)

    def test_invalid_runs_are_one_passage_not_forged_verses(self):
        for numbers in ((1, 3), (1, 1), (2, 1), (0, 1)):
            with self.subTest(numbers=numbers):
                verses, _, passage = source._chapter(chapter(''.join(
                    f'<p><strong>{n}</strong> Text {n}.</p>' for n in numbers)))
                self.assertTrue(passage)
                self.assertEqual(list(verses), [1])
                self.assertEqual(verses[1].count('Text'), 2)

    def test_no_superscript_or_prose_number_guessing(self):
        for text in ('First ¹ ambiguous ¹¹ ending.', '1. First 2. Second.', '<sup>1</sup> First <sup>1</sup> Second.'):
            verses, _, passage = source._chapter(chapter(f'<p>{text}</p>'))
            self.assertTrue(passage)
            self.assertEqual(list(verses), [1])
            self.assertIn('First', verses[1])

    def test_empty_marker_does_not_become_empty_verse(self):
        verses, _, passage = source._chapter(chapter('<p><strong>1</strong></p>'))
        self.assertTrue(passage)
        self.assertEqual(verses, {1: '1'})

    def test_entity_declaration_rejected(self):
        with self.assertRaisesRegex(ValueError, 'Entity'):
            source._xml(b'<!DOCTYPE x [<!ENTITY a SYSTEM "file:///etc/passwd">]><x>&a;</x>')

    def test_pinned_hash_rejected_before_parsing(self):
        calls = []
        def fetch(url, cache):
            calls.append((url, cache))
            return b'changed archive'
        with self.assertRaisesRegex(ValueError, 'SHA256'):
            source.load_components(fetch)
        self.assertEqual(calls, [(source.SOURCE_URL, source.CACHE_NAME)])

    def test_loader_contract_metadata_and_honest_missing_chapter(self):
        data = fixture()
        with patch.object(source, 'SOURCE_SHA256', hashlib.sha256(data).hexdigest()):
            books, meta = source.load_components(lambda url, cache: data)
        self.assertEqual(set(books), {'1MQ', '2MQ', '3MQ'})
        self.assertNotIn(1, books['1MQ'])
        self.assertEqual([len(books[k]) for k in source.BOOK_MEMBERS], [35, 21, 10])
        self.assertTrue(all(isinstance(v, str) for v in meta.values()))
        self.assertEqual(json.loads(meta['incomplete_books']), {'1MQ': [1]})
        self.assertEqual(json.loads(meta['passage_books']), [])
        self.assertIn('UNREVIEWED', meta['caveat'])
        self.assertIn('Bogdan Zorlescu', meta['attribution'])
        self.assertFalse(json.loads(meta['inventory'])['1MQ']['complete'])
        self.assertIn('Note on the reading', json.loads(meta['source_structure'])['2MQ']['1']['notes_xhtml'])

    def test_download_retry_uses_same_cache_and_pinned_bytes(self):
        data, calls = fixture(), []
        def fetch(url, cache):
            calls.append((url, cache))
            if len(calls) == 1:
                raise OSError('temporary archive error')
            return data
        with patch.object(source, 'SOURCE_SHA256', hashlib.sha256(data).hexdigest()):
            _, meta = source.load_components(fetch)
        self.assertEqual(calls[1], (source.SOURCE_URL + '?download=1', source.CACHE_NAME))
        self.assertEqual(json.loads(meta['sources'])[0]['retrieved_url'], calls[1][0])

    @unittest.skipUnless(os.getenv('ETHIOPIAN_COMPONENTS_LIVE') == '1', 'explicit network opt-in')
    def test_actual_pinned_epub(self):
        def fetch(url, cache):
            with urllib.request.urlopen(url, timeout=30) as response:
                return response.read()
        books, meta = source.load_components(fetch)
        self.assertEqual([sum(map(len, books[k].values())) for k in source.BOOK_MEMBERS], [728, 424, 208])
        self.assertIn('Maqabis', books['1MQ'][2][1])
        self.assertIn('Amen', books['1MQ'][36][46])
        self.assertIn('Amen', books['2MQ'][21][28])
        self.assertIn('Amen', books['3MQ'][10][29])
        self.assertEqual(json.loads(meta['passage_books']), [])
        for chapters in books.values():
            for verses in chapters.values():
                self.assertEqual(list(verses), list(range(1, len(verses) + 1)))
                self.assertTrue(all(text.strip() for text in verses.values()))
        print(json.dumps({'inventory': json.loads(meta['inventory']), 'sha256': meta['source_sha256']}))


if __name__ == '__main__':
    unittest.main()