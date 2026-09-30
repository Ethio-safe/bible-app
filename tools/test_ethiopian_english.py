"""Offline unit tests; optional pinned-corpus test with ETHIOPIAN_ENGLISH_LIVE=1."""

import copy
import json
import os
import unittest
import urllib.request

try:
    from . import ethiopian_english as source
except ImportError:
    import ethiopian_english as source


class EnglishCollectionTest(unittest.TestCase):
    def test_hash_rejected_and_fetch_contract(self):
        calls = []
        def fetch(url, cache):
            calls.append((url, cache))
            return b"not the reviewed archive"
        with self.assertRaisesRegex(ValueError, "SHA256"):
            source.load_english(fetch)
        self.assertEqual(calls, [(source.SOURCE_URL, source.CACHE_NAME)])

    def test_actual_ambiguous_meqabyan_snippet_is_not_guessed(self):
        # 1 Meqabyan 1:3: damaged ¹ cannot safely be interpreted as 10.
        text = ("and sacrifice like unto them. ¹ But him would trust in him idols "
                "that don't profit nor benefit. ¹¹ By him timeframe bein small")
        self.assertEqual(source._split_markers(3, text, None), {3: text})
        self.assertEqual(source._split_markers(3, text, 12), {3: text})

    def test_only_complete_anchored_superscript_sequences_split(self):
        # Synthetic complete markers contrast with the actual truncated source.
        text = "First. ⁴ Second. ⁵ Third."
        self.assertEqual(source._split_markers(3, text, 6),
                         {3: "First.", 4: "Second.", 5: "Third."})
        for value in ("First. ⁴ Second. ⁶ Third.", "First. 4 Second. 5 Third.",
                      "First. ⁴ ⁵ Third."):
            self.assertEqual(source._split_markers(3, value, 6), {3: value})
        self.assertEqual(source._split_markers(3, text, None), {3: text})

    def test_actual_daniel_header_preserves_scripture(self):
        text = ("a burning fiery furnace. Daniel (Greek) 3:16 1008 "
                'Daniel (Greek) 3:39 Who is that god who will deliver you out of my hands?"')
        audit = []
        cleaned = source._remove_metadata(text, "DAG", "Daniel Greek Additions", "DAG 3:15", audit)
        self.assertEqual(cleaned, 'a burning fiery furnace. Who is that god who will deliver you out of my hands?"')
        self.assertEqual(audit[0]["original"], text)

    def test_actual_proverbs_footer_fragment(self):
        text = "Give her of the fruit of her hands! Let her works praise her in the gates! lxxiv The World English Bible The World"
        self.assertEqual(source._remove_metadata(text, "PRO", "Proverbs", "PRO 31:31", []),
                         "Give her of the fruit of her hands! Let her works praise her in the gates!")

    def test_duplicates_notes_and_gaps_preserved(self):
        catalog, payload = [], {}
        for slug in source.SOURCE_CODES:
            entry = {"slug": slug, "title": slug, "category": "ot",
                     "chapters": [{"n": 1, "label": slug, "verses": 3}]}
            catalog.append(entry)
            payload[slug] = {**entry, "chapters": [{"n": 1, "label": slug,
                "note": "Greek addition; legitimate scripture fragment.",
                "sections": [{"title": "Preserve section"}],
                "verses": [{"v": 1, "t": " First\u00a0part. "},
                           {"v": 1, "t": "Second part."}, {"v": 3, "t": "Third."}]}]}
        original = copy.deepcopy(payload)
        books, meta = source._convert(catalog, payload)
        self.assertEqual(payload, original)
        self.assertEqual(books[0]["chapters"][1], {1: "First part. Second part.", 3: "Third."})
        self.assertTrue(all(isinstance(v, str) for v in meta.values()))
        ch = json.loads(meta["source_structure"])["GEN"]["chapters"]["1"]
        self.assertEqual(ch["note"], payload["genesis"]["chapters"][0]["note"])
        self.assertEqual(len(ch["original_verse_records"]), 3)
        self.assertEqual(ch["sections"], [{"title": "Preserve section"}])
        defects = json.loads(meta["quality_notes"])["defects"]
        self.assertIn({"kind": "verse_number_gaps", "ref": "GEN 1", "numbers": [2]}, defects)

    @unittest.skipUnless(os.getenv("ETHIOPIAN_ENGLISH_LIVE") == "1", "explicit opt-in network test")
    def test_pinned_corpus(self):
        def fetch(url, cache):
            with urllib.request.urlopen(url, timeout=120) as response:
                return response.read()
        books, meta = source.load_english(fetch)
        mapped = {b["source_id"]: b for b in books}
        self.assertEqual(len(mapped), 81)
        self.assertEqual(sum(b["testament"] == "NT" for b in books), 27)
        self.assertEqual(set(mapped["DAG"]["chapters"]), {3, 13, 14})
        self.assertIn(151, mapped["PSA"]["chapters"])
        self.assertEqual(mapped["ECC"]["chapters"][5], {})
        self.assertIn(930, mapped["JUB"]["chapters"][4])
        self.assertIn(364, mapped["ENO"]["chapters"][74])
        self.assertIn(146, mapped["PSA"]["chapters"][147])
        self.assertNotIn("World English Bible", mapped["EST"]["chapters"][10][3])
        self.assertTrue(all(t.strip() for b in books for c in b["chapters"].values() for t in c.values()))
        notes = json.loads(meta["source_structure"])
        self.assertIn("Greek Addition F", notes["EST"]["chapters"]["10"]["note"])
        self.assertIn("Septuagint expansion", notes["PRO"]["chapters"]["31"]["cleaned_note"])
        self.assertNotIn("Public Domain", notes["PRO"]["chapters"]["31"]["cleaned_note"])
        defects = json.loads(meta["quality_notes"])["defects"]
        from collections import Counter
        self.assertEqual(Counter(d["kind"] for d in defects)["duplicate_reference"], 15)
        self.assertEqual(json.loads(meta["quality_notes"])["counts"]["marker_splits"], 0)
        print("\nCorpus defects:", dict(Counter(d["kind"] for d in defects)))
        print("Cleanup:", dict(Counter(d["kind"] for d in json.loads(meta["cleanup_audit"]))))
        print("Verse records:", sum(len(c) for b in books for c in b["chapters"].values()))


if __name__ == "__main__":
    unittest.main()