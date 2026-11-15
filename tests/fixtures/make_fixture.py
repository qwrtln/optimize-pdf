#!/usr/bin/env python3

"""
Fonts and ToUnicode maps must stay as LuaTeX wrote them, so the fixture breaks
under Ghostscript like the full document. Only images are shrunk.
"""

import argparse

import pikepdf


def main():
    parser = argparse.ArgumentParser(description="Cut a small text-only fixture from a PDF.")
    parser.add_argument("source")
    parser.add_argument("pages", help='1-based page numbers, e.g. "13,20"')
    parser.add_argument("output")
    args = parser.parse_args()

    keep = [int(p) - 1 for p in args.pages.split(",")]
    with pikepdf.open(args.source) as src, pikepdf.new() as out:
        for index in keep:
            out.pages.append(src.pages[index])
        for obj in out.objects:
            if isinstance(obj, pikepdf.Stream) and obj.get("/Subtype") == "/Image":
                for key in list(obj.keys()):
                    if key != "/Length":
                        del obj[key]
                obj.write(b"\x80")
                obj.Type = pikepdf.Name.XObject
                obj.Subtype = pikepdf.Name.Image
                obj.Width = 1
                obj.Height = 1
                obj.BitsPerComponent = 8
                obj.ColorSpace = pikepdf.Name.DeviceGray
        out.remove_unreferenced_resources()
        out.save(
            args.output,
            compress_streams=True,
            object_stream_mode=pikepdf.ObjectStreamMode.generate,
        )


if __name__ == "__main__":
    main()
