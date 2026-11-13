"""Builds the app's optimised Noto Arabic fonts from the upstream files.

Usage (from the quran_app directory; needs `pip install fonttools`):
    python tool/fonts/optimize_fonts.py

The upstream Noto fonts are variable fonts carrying every weight, but the app
only ever draws the regular weight. This pins them to their default (regular)
instance and drops glyphs for scripts the app never shows, cutting their
compressed size by over 80%. Kept: the complete Arabic script blocks, Basic
Latin and Latin-1, general punctuation, the dotted circle, every code point
of the bundled Uthmani text and daily hadith, and ALL OpenType layout
features (shaping, marks and ligatures are untouched).

Only fonts whose licence reserves no font name are processed (OFL section
"Reserved Font Name"): Noto Sans Arabic and Noto Naskh Arabic. Their OFL
licences stay bundled. test/core/quran_fonts_test.dart checks that every
Quran font still covers every code point of the Uthmani text.
"""

import json
import sqlite3
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'tool' / 'fonts' / 'source'
OUTPUT = ROOT / 'assets' / 'fonts'

FONTS = {
    'NotoSansArabic-Variable.ttf': 'NotoSansArabic-Regular.ttf',
    'NotoNaskhArabic-Variable.ttf': 'NotoNaskhArabic-Regular.ttf',
}

RANGES = [
    (0x0020, 0x007E),  # Basic Latin
    (0x00A0, 0x00FF),  # Latin-1 punctuation and symbols
    (0x0600, 0x06FF),  # Arabic
    (0x0750, 0x077F),  # Arabic Supplement
    (0x08A0, 0x08FF),  # Arabic Extended-A
    (0xFB50, 0xFDFF),  # Arabic Presentation Forms-A
    (0xFE70, 0xFEFF),  # Arabic Presentation Forms-B
    (0x2000, 0x206F),  # General Punctuation (joiners, marks)
    (0x25CC, 0x25CC),  # Dotted circle, for isolated marks
]


def needed_code_points():
    points = set()
    for start, end in RANGES:
        points.update(range(start, end + 1))
    db = sqlite3.connect(ROOT / 'assets' / 'db' / 'quran.db')
    for (text,) in db.execute('SELECT text_uthmani FROM ayah'):
        points.update(map(ord, text))
    for (text,) in db.execute('SELECT name_arabic FROM surah'):
        points.update(map(ord, text))
    db.close()
    daily = json.loads(
        (ROOT / 'assets' / 'daily' / 'daily_content.json').read_text('utf-8')
    )
    for hadith in daily['hadiths']:
        points.update(map(ord, hadith['arabic']))
    return points


def optimise(source, target, points):
    font = TTFont(source)
    if 'fvar' in font:
        defaults = {axis.axisTag: axis.defaultValue for axis in font['fvar'].axes}
        font = instancer.instantiateVariableFont(font, defaults)

    options = subset.Options()
    options.layout_features = ['*']
    options.layout_closure = True
    options.name_IDs = ['*']
    options.name_languages = ['*']
    options.name_legacy = True
    options.notdef_outline = True
    options.hinting = True
    subsetter = subset.Subsetter(options)
    subsetter.populate(unicodes=points)
    subsetter.subset(font)
    font.save(target)
    print(f'{target.name}: {source.stat().st_size // 1024} KB -> '
          f'{target.stat().st_size // 1024} KB')


def main():
    points = needed_code_points()
    for source_name, target_name in FONTS.items():
        optimise(SOURCE / source_name, OUTPUT / target_name, points)


if __name__ == '__main__':
    main()
