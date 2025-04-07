# PDF Optimizer

This action optimizes PDF files using Ghostscript, verifies their integrity, and provides file size metrics.
It's primary purpose is to serve Rule Book Rewrite and Fan-Made Mission Book repositories, although it should work with any PDF file built in the CI.

## Usage

### Inputs

```yaml
- uses: qwrtln/optimize-pdf@v1
  with:
    # Input file. Must be in PDF format.
    # Required.
    file-name:

    # File to write to.
    # Optional. Overwrites input file, if unspecified.
    output-file:

    # Ghostscript's quality level for optimization: scree, ebook, printer, prepress, default (see below for details).
    # Optional. Defaults to prepress.
    quality-level:

    # Text to look for in the resulting PDF file to detect broken CMap integroty.
    # Ghostscript 10.04 would break it for files built with LuaLaTeX.
    # Optional. The check is skipped if unspecified.
    test-string:

    # Whether to convert colors to CMYK color space for optimized printing.
    # Optional. Defaults to false.
    convert-to-cmyk:
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
  uses: actions/checkout@v4

- name: Optimize PDF
  uses: qwrtln/optimize-pdf@v1
  with:
    file-name: 'documentation.pdf'
```

### Complete Example

```yaml
- name: Optimize PDF with Verification
  id: optimize
  uses: qwrtln/optimize-pdf@v1
  with:
    file-name: 'documentation.pdf'
    output-file: 'documentation-optimized.pdf'
    quality-level: 'ebook'
    test-string: 'Copyleft 2025'
    convert-to-cmyk: 'true'

- name: Use optimization results
  run: |
    echo "The optimized PDF has ${{ steps.optimize.outputs.page-count }} pages"
```
