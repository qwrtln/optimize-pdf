#!/usr/bin/env bash
set -e

FILE_NAME=$1
QUALITY_LEVEL=$2
CONVERT_TO_CMYK=$3
TEST_STRING=$4

echo "Processing file: ${FILE_NAME}"
echo "Quality level: ${QUALITY_LEVEL}"
echo "Convert to CMYK: ${CONVERT_TO_CMYK}"

if [[ ! -f "${FILE_NAME}" ]]; then
  echo "Error: File ${FILE_NAME} does not exist"
  exit 1
fi

/optimize.sh "${FILE_NAME}" "${QUALITY_LEVEL}" "${CONVERT_TO_CMYK}"

PAGE_COUNT=$(pdfinfo "${FILE_NAME}" | awk '/^Pages:/ {print $2}')
echo "page-count=${PAGE_COUNT}" >> "$GITHUB_OUTPUT"

# Check for broken CMap if test string is provided
if [[ -n "${TEST_STRING}" ]]; then
  echo "Checking CMap integrity with test string: ${TEST_STRING}"
  
  pdftotext "${FILE_NAME}" - | tr '\n' ' ' > "${FILE_NAME}.txt"
  if grep -iq "${TEST_STRING}" "${FILE_NAME}.txt"; then
    echo "✅ CMap integrity check passed"
  else
    echo "❌ The CMap in ${FILE_NAME} file is broken"
    exit 1
  fi
fi

echo "PDF optimization completed successfully"
