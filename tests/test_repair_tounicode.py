"""
Run inside the action image: Ghostscript's damage depends on its version.
"""

import collections
import contextlib
import io
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FIXTURES = Path(__file__).resolve().parent / "fixtures"
sys.path.insert(0, str(ROOT))

import repair_tounicode as repair  # noqa: E402

HAVE_TOOLS = bool(shutil.which("gs") and shutil.which("pdftotext"))


class ParseCmapTest(unittest.TestCase):
    def test_bfchar_and_bfrange(self):
        text = (
            "2 beginbfchar\n<0003> <0041>\n<0004> <00660066>\nendbfchar\n"
            "1 beginbfrange\n<0010> <0012> <0061>\nendbfrange"
        )
        self.assertEqual(
            repair.parse_cmap(text),
            {3: "0041", 4: "00660066", 0x10: "0061", 0x11: "0062", 0x12: "0063"},
        )


class PickSourceTest(unittest.TestCase):
    current = {1: "0061", 2: "0062", 3: "00CF", 4: "0064"}
    right = {1: "0061", 2: "0062", 3: "006600660069", 4: "0064"}
    other = {1: "0058", 2: "0059", 3: "005A", 4: "0021"}

    def test_prefers_same_font_type(self):
        candidates = [("/Type1", self.right), ("/Type0", self.other)]
        self.assertIs(repair.pick_source(candidates, "/Type1", self.current), self.right)
        # Borrowing another font type's map would garble the text.
        self.assertIsNone(repair.pick_source(candidates, "/Type0", self.current))

    def test_picks_best_agreement_within_type(self):
        candidates = [("/Type0", self.other), ("/Type0", self.right)]
        self.assertIs(repair.pick_source(candidates, "/Type0", self.current), self.right)

    def test_falls_back_to_any_type(self):
        candidates = [("/Type1", self.right)]
        self.assertIs(repair.pick_source(candidates, "/Type0", self.current), self.right)

    def test_rejects_unrelated_numbering(self):
        self.assertIsNone(repair.pick_source([("/Type0", self.other)], "/Type0", self.current))


# Ghostscript moves hyphens and adds invisible bidi marks to Hebrew without
# changing a letter.
IGNORED = r"\s\-" + re.escape("".join(map(chr, [
    0xAD, 0x200E, 0x200F, *range(0x202A, 0x202F), *range(0x2066, 0x206A),
])))


def text_chars(pdf):
    # A multiset: Ghostscript may change the reading order.
    out = subprocess.run(["pdftotext", str(pdf), "-"], capture_output=True, check=True)
    text = out.stdout.decode("utf-8")
    return collections.Counter(
        re.sub("[" + IGNORED + "]", "", text)
    )


def ghostscript(source, output, cmyk):
    args = [
        "gs", "-q", "-o", str(output),
        "-sDEVICE=pdfwrite",
        "-dCompatibilityLevel=1.7",
        "-dPDFSETTINGS=/prepress",
        "-dDetectDuplicateImages=true",
    ]
    if cmyk:
        args.append("-sColorConversionStrategy=CMYK")
    subprocess.run(args + [str(source)], check=True, capture_output=True)


LANGUAGES = {
    "en": "doing this out of the love",
    "pl": "Robię to z zamiłowania",
    "es": "porque me apasiona aprender",
    "fr": "réalisé ce projet par amour",
    "ru": "делаю это из любви",
    "ua": "Я роблю це з любові",
    "de": "Ich tue dies aus Liebe",
    "cs": "Dělám to z lásky",
    "he": "אני עושה זאת",
    "cn": "我做这件事",
}


@unittest.skipUnless(HAVE_TOOLS, "needs gs and pdftotext")
class EndToEndTest(unittest.TestCase):
    def check(self, lang, cmyk):
        source = FIXTURES / f"rulebook_{lang}.pdf"
        with tempfile.TemporaryDirectory() as tmp:
            gs_pdf = Path(tmp) / "gs.pdf"
            repaired = Path(tmp) / "repaired.pdf"
            ghostscript(source, gs_pdf, cmyk)
            with contextlib.redirect_stdout(io.StringIO()), \
                    contextlib.redirect_stderr(io.StringIO()):
                repair.repair(str(source), str(gs_pdf), str(repaired))

            want, got = text_chars(source), text_chars(repaired)
            self.assertEqual(
                (dict(got - want), dict(want - got)), ({}, {}),
                "characters added / lost after repair",
            )
            out = subprocess.run(["pdftotext", str(repaired), "-"], capture_output=True)
            flat = " ".join(out.stdout.decode("utf-8").split())
            self.assertIn(LANGUAGES[lang], flat)

    def test_digital(self):
        for lang in LANGUAGES:
            with self.subTest(lang=lang):
                self.check(lang, cmyk=False)

    def test_cmyk(self):
        for lang in LANGUAGES:
            with self.subTest(lang=lang):
                self.check(lang, cmyk=True)


if __name__ == "__main__":
    unittest.main()
