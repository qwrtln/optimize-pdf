# PDF Optimizer

This action optimizes PDF files using Ghostscript, verifies their integrity, and provides file size metrics.
Perfect for reducing the size of documentation, reports, and other PDF assets in your repositories.

## Features

- 📏 Reduces PDF file size with configurable quality settings
- ✅ Verifies PDF integrity with custom text verification
- 🎨 Optional CMYK color space conversion for print-ready files
- 📊 Reports original and optimized file sizes
- 📄 Counts pages in the optimized PDF

## Usage

```yaml
- name: Optimize PDF
  uses: qwrtln/optimize-pdf@v1
  with:
    file-name: 'document.pdf'
    quality-level: 'prepress'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|:--------:|:-------:|
| `file-name` | PDF file to optimize | Yes | - |
| `output-file` | Output file path (if not specified, input file will be overwritten) | No | - |
| `quality-level` | Quality level for optimization: `screen`, `ebook`, `printer`, `prepress`, `default` | No | `prepress` |
| `test-string` | Test string to verify text integrity in the PDF after optimization | No | - |
| `convert-to-cmyk` | Whether to convert colors to CMYK color space | No | `false` |

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
  uses: actions/checkout@v3

- name: Optimize PDF
  uses: yourusername/pdf-optimizer@v1
  with:
    file-name: 'documentation.pdf'
```

### Complete Example

```yaml
- name: Optimize PDF with Verification
  id: optimize
  uses: yourusername/pdf-optimizer@v1
  with:
    file-name: 'documentation.pdf'
    output-file: 'documentation-optimized.pdf'
    quality-level: 'ebook'
    test-string: 'Copyright 2025'
    convert-to-cmyk: 'true'

- name: Use optimization results
  run: |
    echo "The optimized PDF has ${{ steps.optimize.outputs.page-count }} pages"
```

### Workflow Example: Optimize and Release PDFs

```yaml
name: Optimize and Release PDFs

on:
  push:
    tags:
      - 'v*'

jobs:
  optimize-pdfs:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        
      - name: Optimize Documentation
        id: optimize-docs
        uses: yourusername/pdf-optimizer@v1
        with:
          file-name: 'docs/manual.pdf'
          output-file: 'optimized-manual.pdf'
          quality-level: 'ebook'
          test-string: 'Table of Contents'
      
      - name: Upload Optimized PDF
        uses: actions/upload-artifact@v3
        with:
          name: optimized-documentation
          path: optimized-manual.pdf
          
      - name: Create Release
        uses: softprops/action-gh-release@v1
        if: startsWith(github.ref, 'refs/tags/')
        with:
          files: optimized-manual.pdf
```
