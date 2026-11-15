# Test fixtures

One fixture per language of the [Homm3BG](https://github.com/Heegu-sama/Homm3BG)
rulebook, cut from a real LuaLaTeX build with `make_fixture.py`. Images are
shrunk to one pixel; fonts, ToUnicode maps and text are as LuaTeX wrote them.
The content is licensed CC BY-NC-SA 4.0 by the Homm3BG project.

Every fixture has page 2, which holds the CI test string. The other pages
hold what Ghostscript breaks in that language.

| File | Pages | What Ghostscript does to it |
|---|---|---|
| `rulebook_en.pdf` | 2, 13 | "ffi"/"ffl" become "Ï"/"Ò" |
| `rulebook_es.pdf` | 2, 13 | same |
| `rulebook_fr.pdf` | 2, 13 | same |
| `rulebook_de.pdf` | 2, 56 | "ffi" becomes "Ï" |
| `rulebook_cs.pdf` | 2, 13, 20 | same, plus page 20 has an OT1 Type1 copy of `LMRoman12-Regular` (from Czech babel's `\uv` quotes) next to the OpenType one: same name, different glyph numbering |
| `rulebook_cn.pdf` | 2, 3, 48 | swaps single CJK characters ("目录" becomes "目庯") |
| `rulebook_pl.pdf` | 2, 13 | nothing; the repair must change nothing |
| `rulebook_ru.pdf` | 2, 27 | nothing |
| `rulebook_ua.pdf` | 2, 27 | nothing |
| `rulebook_he.pdf` | 2, 45 | adds invisible bidi marks (U+202A..U+202C), no letter changes |

All fixtures come from commit `b5329b3c`, except `rulebook_cn.pdf`, which
comes from the build of 2026-09-13. Later cn builds no longer trigger the
CJK swap.

To refresh a fixture, build the document and run:

    python make_fixture.py main_xx.pdf 2,13 rulebook_xx.pdf

Then check that the test fails without the repair.
