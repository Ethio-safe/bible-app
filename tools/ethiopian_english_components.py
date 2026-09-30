"""Verified-format English replacement components; no I/O occurs on import.

IMPORTANT: Meqabyan is an AI-assisted, single-witness, UNREVIEWED draft,
not a scholarly replacement for the Ge'ez text. Consumers MUST display
``attribution`` and ``caveat`` and retain ``source_structure``. Source notes
are the translators' claims, not independently verified scholarship.

Only confirmed components are returned. The pinned EPUB actually omits
1 Meqabyan chapter 1: NEVER treat its 35 surviving chapters as a complete
replacement book. Merge by source chapter, disclose the gap, and do not
silently relabel an older chapter as this translation. Expected genuine
book lengths are 36/21/10, not Greek Maccabees' chapter counts.

Charles Enoch/Jubilees downloads could not be confirmed (HTTP 403 during
inspection); those keys and optional 4BA are deliberately NOT returned.
No speculative parser, downloaded code, or invented scripture is used.

``load_components(fetch)`` accepts the builder's (url, cache_name) -> bytes
callable. Metadata values are strings, structured values are JSON. For a
book in ``passage_books``, numeric slot 1 is a storage key, NOT verse 1;
render chapter-only references throughout that book.
"""

from __future__ import annotations

import copy
import hashlib
import io
import json
import re
import xml.etree.ElementTree as ET
import zipfile
from collections.abc import Callable

SOURCE_URL = (
    "https://archive.org/download/three-books-of-meqabyan-cc0-translation/"
    "Three_Books_of_Meqabyan.epub"
)
SOURCE_SHA256 = "02c4e7f5a2145cd1ef3dcb121e72e88ff6954ce7fe011af239fc380d4e3a6f48"
CACHE_NAME = f"meqabyan-cc0-{SOURCE_SHA256}.epub"
EXPECTED_CHAPTERS = {"1MQ": 36, "2MQ": 21, "3MQ": 10}
BOOK_MEMBERS = {
    "1MQ": ("EPUB/text/ch002.xhtml", "The First Book of Meqabyan"),
    "2MQ": ("EPUB/text/ch004.xhtml", "The Second Book of Meqabyan"),
    "3MQ": ("EPUB/text/ch006.xhtml", "The Third Book of Meqabyan"),
}
ATTRIBUTION = (
    "The Three Books of Meqabyan: A CC0 1.0 English Translation from Amharic "
    "(May 2026). Internet Archive credits Claude 4.7 Research (Anthropic), "
    "Bogdan Zorlescu; EPUB title page: Claude (Anthropic) with collaborator. "
    "Modern Amharic EOTC text via nehemiah-osc.org; CC0 1.0 Universal."
)
CAVEAT = (
    "AI-ASSISTED, SINGLE-WITNESS, UNREVIEWED / NOT PEER-REVIEWED DRAFT. "
    "Translated from modern Amharic, not collated against the Ge'ez original. "
    "Readable wording does not establish translation accuracy. Source commentary "
    "and confidence claims are unverified. This is Ethiopian Meqabyan, NOT Greek "
    "Maccabees. The EPUB omits 1 Meqabyan chapter 1 despite its completeness "
    "claim: only chapters 2–36 survive here. Do not advertise a complete corpus."
)
NS = {"h": "http://www.w3.org/1999/xhtml"}
H = "{" + NS["h"] + "}"


def _text(element: ET.Element) -> str:
    return " ".join("".join(element.itertext()).split())


def _xml(data: bytes) -> ET.Element:
    # ElementTree does not resolve external entities. Reject declarations anyway.
    if re.search(br"<!\s*ENTITY", data, re.I):
        raise ValueError("Entity declarations are not allowed")
    return ET.fromstring(data)


def _chapter(section: ET.Element) -> tuple[dict[int, str], str, bool]:
    """Use only paragraph-leading <strong>ASCII-number</strong> markers.

    Notes, tables and blockquotes cannot supply verse markers. Any incomplete,
    duplicate, out-of-order, or missing run falls back to ONE passage; neither
    superscript digits nor numbers inside prose are interpreted as verses.
    """
    parents = {child: parent for parent in section.iter() for child in parent}
    rows = []
    for p in section.iter(H + "p"):
        ancestor = parents.get(p)
        blocked = False
        while ancestor is not None:
            if ancestor.tag in {H + "blockquote", H + "table", H + "aside"}:
                blocked = True
            ancestor = parents.get(ancestor)
        if blocked or not len(p) or (p.text or "").strip():
            continue
        marker = p[0]
        if marker.tag != H + "strong" or not re.fullmatch(r"[0-9]+", _text(marker)):
            continue
        number = int(_text(marker))
        prose = copy.deepcopy(p)
        first = prose[0]
        prose.text = (prose.text or "") + (first.tail or "")
        prose.remove(first)
        rows.append((number, _text(prose), p))

    # Preserve ALL non-verse source material, including introductory prose,
    # blockquote verse notes, confidence tables and chapter titles, as XML.
    notes = copy.deepcopy(section)
    original_nodes = list(section.iter())
    copied_nodes = list(notes.iter())
    copies = dict(zip(original_nodes, copied_nodes))
    for _, _, node in rows:
        copies[parents[node]].remove(copies[node])
    notes_xml = ET.tostring(notes, encoding="unicode")
    nums = [number for number, _, _ in rows]
    valid = nums == list(range(1, len(rows) + 1)) and bool(rows)
    valid = valid and all(text for _, text, _ in rows)
    if valid:
        return {number: text for number, text, _ in rows}, notes_xml, False
    # Keep even ambiguous marker text verbatim; do not reconstruct verse labels.
    passage = "\n\n".join(_text(node) for _, _, node in rows) if rows else _text(section)
    if not passage:
        raise ValueError("Empty reading chapter")
    return {1: passage}, notes_xml, True


def _parse_epub(data: bytes) -> tuple[dict, dict, dict, set[str]]:
    books, structure, frontmatter, passage_books = {}, {}, {}, set()
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        infos = archive.infolist()
        names = [i.filename for i in infos]
        if len(names) != len(set(names)) or len(names) > 200:
            raise ValueError("Duplicate or excessive EPUB members")
        if any(i.file_size > 5_000_000 for i in infos) or sum(i.file_size for i in infos) > 20_000_000:
            raise ValueError("EPUB exceeds size limit")
        if archive.read("mimetype") != b"application/epub+zip":
            raise ValueError("Not an EPUB")
        # Read only named XML documents, never extract files or execute content.
        for code, (member, title) in BOOK_MEMBERS.items():
            root = _xml(archive.read(member))
            heading = root.find(".//h:h1", NS)
            if heading is None or _text(heading) != title:
                raise ValueError(f"Unexpected book identity: {code}")
            chapters, details = {}, {}
            chapter_nodes = []
            for section in root.iter(H + "section"):
                heading = section.find("h:h2", NS)
                match = re.fullmatch(r"Chapter ([0-9]+)", _text(heading)) if heading is not None else None
                if match is None:
                    continue
                ch = int(match[1])
                if ch in chapters or not 1 <= ch <= EXPECTED_CHAPTERS[code]:
                    raise ValueError(f"Duplicate or invalid chapter: {code} {ch}")
                verses, notes, passage = _chapter(section)
                chapters[ch] = verses
                details[ch] = {"source_member": member, "notes_xhtml": notes,
                               "numbering": "passage" if passage else "source_verses"}
                if passage:
                    passage_books.add(code)
                chapter_nodes.append(section)
            expected = set(range(2 if code == "1MQ" else 1, EXPECTED_CHAPTERS[code] + 1))
            if set(chapters) != expected:
                raise ValueError(f"Unexpected chapter inventory: {code}")
            # Preserve prefaces outside chapters as well as separate closing notes.
            parents = {child: parent for parent in root.iter() for child in parent}
            for section in chapter_nodes:
                parents[section].remove(section)
            frontmatter[member] = ET.tostring(root, encoding="unicode")
            books[code], structure[code] = chapters, details
        for member in names:
            if member.endswith((".xhtml", ".opf")) and member not in frontmatter:
                frontmatter[member] = archive.read(member).decode("utf-8")
    return books, structure, frontmatter, passage_books


def load_components(fetch: Callable[[str, str], bytes]) -> tuple[dict[str, dict[int, dict[int, str]]], dict[str, str]]:
    """Return confirmed partial replacements plus mandatory provenance/disclosures.

    Fail closed on digest/format drift. HTTP failures may retry the same archive
    item with its download query parameter; no other translation is substituted.
    """
    url = SOURCE_URL
    try:
        data = fetch(url, CACHE_NAME)
    except OSError:
        url = SOURCE_URL + "?download=1"
        data = fetch(url, CACHE_NAME)
    digest = hashlib.sha256(data).hexdigest()
    if digest != SOURCE_SHA256:
        raise ValueError("Source SHA256 mismatch; refusing changed Meqabyan EPUB")
    books, structure, frontmatter, passage_books = _parse_epub(data)
    inventory = {
        code: {"expected_chapters": EXPECTED_CHAPTERS[code],
               "chapters": sorted(chapters), "chapter_count": len(chapters),
               "missing_chapters": sorted(set(range(1, EXPECTED_CHAPTERS[code] + 1)) - chapters.keys()),
               "records": sum(len(v) for v in chapters.values()),
               "complete": len(chapters) == EXPECTED_CHAPTERS[code]}
        for code, chapters in books.items()
    }
    meta = {
        "attribution": ATTRIBUTION,
        "caveat": CAVEAT,
        "license": "CC0 1.0 Universal (Public Domain Dedication)",
        "license_url": "https://creativecommons.org/publicdomain/zero/1.0/",
        "source_url": SOURCE_URL,
        "source_sha256": digest,
        "cache_name": CACHE_NAME,
        "sources": [{"url": SOURCE_URL, "retrieved_url": url, "sha256": digest,
                     "cache_name": CACHE_NAME, "pinned": True}],
        "passage_books": sorted(passage_books),
        "passage_policy": "For passage_books use chapter-only references; slot 1 is not a biblical verse number.",
        "inventory": inventory,
        "source_structure": structure,
        "source_frontmatter": frontmatter,
        "incomplete_books": {"1MQ": [1]},
        "unavailable_components": {
            "ENO": {"url": "https://archive.sacred-texts.com/bib/boe/",
                    "reason": "Charles 1917 source download returned HTTP 403 during implementation; not imported."},
            "JUB": {"url": "https://archive.sacred-texts.com/bib/jub/",
                    "reason": "Charles 1917 source download returned HTTP 403 during implementation; not imported."},
            "4BA": {"reason": "No replacement source confirmed within timebox."}},
        "quality_notes": "1MQ 2–36, 2MQ 1–21, 3MQ 1–10. No words supplied or superscripts reconstructed. Source verse boundaries, not an independent verification of translation or completeness within verses.",
    }
    return books, {key: value if isinstance(value, str) else json.dumps(value, ensure_ascii=False, sort_keys=True)
                   for key, value in meta.items()}