#!/usr/bin/env bash
set -e

FILE_NAME=$1
QUALITY_LEVEL=$2
CONVERT_TO_CMYK=$3
TEST_STRING=$4
OUTPUT_FILE=$5

echo "Processing file: ${FILE_NAME}"
echo "Quality level: ${QUALITY_LEVEL}"
echo "Convert to CMYK: ${CONVERT_TO_CMYK}"
if [[ -n "${OUTPUT_FILE}" ]]; then
  echo "Output file: ${OUTPUT_FILE}"
fi

if [[ ! -f "${FILE_NAME}" ]]; then
  echo "Error: File ${FILE_NAME} does not exist"
  exit 1
fi

/optimize.sh "${FILE_NAME}" "${QUALITY_LEVEL}" "${CONVERT_TO_CMYK}" "${OUTPUT_FILE}"

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
    echo "❌ The CMap in ${CHECK_FILE} file is broken"
    exit 1
  fi
fi

echo "PDF optimization completed successfully"
