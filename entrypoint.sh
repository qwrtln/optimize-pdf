#!/usr/bin/env bash
set -e

FILE_NAME=""
QUALITY_LEVEL="prepress"
CONVERT_TO_CMYK="false"
TEST_STRING=""
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file-name)
      FILE_NAME="$2"
      shift 2
      ;;
    --quality-level)
      QUALITY_LEVEL="$2"
      shift 2
      ;;
    --convert-to-cmyk)
      CONVERT_TO_CMYK="$2"
      shift 2
      ;;
    --test-string)
      TEST_STRING="$2"
      shift 2
      ;;
    --output-file)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "${FILE_NAME}" ]]; then
  echo "Error: file-name is required"
  exit 1
fi

if [[ ! -f "${FILE_NAME}" ]]; then
  echo "Error: File ${FILE_NAME} does not exist"
  exit 1
fi

echo "Processing file: ${FILE_NAME}"
echo "Quality level: ${QUALITY_LEVEL}"
echo "Convert to CMYK: ${CONVERT_TO_CMYK}"
if [[ -n "${OUTPUT_FILE}" ]]; then
  echo "Output file: ${OUTPUT_FILE}"
fi

/optimize.sh \
  --file-name "${FILE_NAME}" \
  --quality-level "${QUALITY_LEVEL}" \
  --convert-to-cmyk "${CONVERT_TO_CMYK}" \
  --output-file "${OUTPUT_FILE}"

# Determine which file to check for page count
CHECK_FILE="${FILE_NAME}"
if [[ -n "${OUTPUT_FILE}" ]]; then
  CHECK_FILE="${OUTPUT_FILE}"
fi

PAGE_COUNT=$(pdfinfo "${CHECK_FILE}" | awk '/^Pages:/ {print $2}')
echo "page-count=${PAGE_COUNT}" >> "$GITHUB_OUTPUT"

# Check for broken CMap if test string is provided
if [[ -n "${TEST_STRING}" ]]; then
  echo "Checking CMap integrity with test string: ${TEST_STRING}"
  pdftotext "${CHECK_FILE}" - | tr '\n' ' ' > "${CHECK_FILE}.txt"
  if grep -iq "${TEST_STRING}" "${CHECK_FILE}.txt"; then
    echo "✅ CMap integrity check passed"
  else
    echo "❌ Test string not found, it's possible the CMap in ${CHECK_FILE} file is broken"
    exit 1
  fi
fi

echo "PDF optimization completed successfully"
