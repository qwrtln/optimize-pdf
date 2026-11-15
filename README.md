# PDF Optimizer

This action optimizes PDF files using Ghostscript, verifies their integrity, and provides file size metrics.
It's primary purpose is to serve [Rule Book Rewrite](https://github.com/Heegu-sama/Homm3BG) and [Fan-Made Mission Book](https://github.com/qwrtln/Homm3BG-mission-book) repositories, although it should work with any PDF file built in the CI.

Action releases are versioned to match the upstream Ghostscript release they ship.

## Usage

### Inputs

```yaml
- uses: qwrtln/optimize-pdf@v10.08
  with:
    # Input PDF file path.
    # Required.
    file-name: 

    # Output file path.
    # Optional. If not specified, the input file will be overwritten.
    output-file: 

    # Ghostscript quality level for optimization.
    # Options: "screen", "ebook", "printer", "prepress", "default"
    # Optional. Defaults to "prepress".
    quality-level: 

    # Text string to search for in the optimized PDF to verify CMap integrity.
    # This helps detect issues that can occur with Ghostscript 10.04 in LuaLaTeX-generated PDFs.
    # Optional. CMap integrity check is skipped if not specified.
    test-string: 

    # Convert colors to CMYK color space for printing.
    # Optional. Defaults to "false".
    convert-to-cmyk: 

    # Restore the text that Ghostscript breaks in LuaLaTeX-generated PDFs: the
    # "ffi" and "ffl" ligatures ("difficult" extracts as "difÏcult") and some
    # CJK characters. Each optimized font gets the ToUnicode entries of its own
    # font in the original PDF, also when several fonts share one name.
    # Optional. Defaults to "true".
    repair-tounicode: 
```

## Outputs

| Output | Description |
|--------|-------------|
| `page-count` | Number of pages in the optimized PDF |

## Quality Levels

- `screen`: Low-resolution output (72 dpi) with maximum compression
- `ebook`: Medium-resolution output (150 dpi) with medium compression
- `printer`: High-resolution output (300 dpi) with less compression
- `prepress`: High-resolution output (300 dpi) with minimal compression, preserving color accuracy
- `default`: Uses default Ghostscript settings

## Examples

### Basic Usage

```yaml
- name: Checkout
  uses: actions/checkout@v6

- name: Optimize PDF
  uses: qwrtln/optimize-pdf@v10.08
  with:
    file-name: 'documentation.pdf'
```

### Complete Example

```yaml
- name: Optimize PDF with Verification
  id: optimize
  uses: qwrtln/optimize-pdf@v10.08
  with:
    file-name: 'documentation.pdf'
    output-file: 'documentation-optimized.pdf'
    quality-level: 'ebook'
    test-string: 'Copyleft 2027'
    convert-to-cmyk: 'true'

- name: Use optimization results
  run: |
    echo "The optimized PDF has ${{ steps.optimize.outputs.page-count }} pages"
```
