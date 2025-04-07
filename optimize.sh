#!/usr/bin/env bash
set -e

FILE_NAME=""
QUALITY="prepress"
CMYK="false"
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file-name)
      FILE_NAME="$2"
      shift 2
      ;;
    --quality-level)
      QUALITY="$2"
      shift 2
      ;;
    --convert-to-cmyk)
      CMYK="$2"
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

EXTENSION="${FILE_NAME##*.}"
BASE_NAME="${FILE_NAME%.*}"

if [[ -z "${OUTPUT_FILE}" ]]; then
  FINAL_OUTPUT="${FILE_NAME}"
  TEMP_OUTPUT="${BASE_NAME}_optimized.${EXTENSION}"
else
  FINAL_OUTPUT="${OUTPUT_FILE}"
  TEMP_OUTPUT="${OUTPUT_FILE}"
fi

if [[ "${CMYK}" == "true" ]]; then
  echo "Adding CMYK conversion arguments"
  ARGS=-sColorConversionStrategy=CMYK
fi

ORIGINAL_SIZE=$(du -sk "${FILE_NAME}" | cut -f1)
ORIGINAL_SIZE_HUMAN=$(du -sh "${FILE_NAME}" | cut -f1)

gs -o "${TEMP_OUTPUT}" \
  -sDEVICE=pdfwrite \
  -dCompatibilityLevel=1.7 \
  -dPDFSETTINGS=/${QUALITY} \
  -dDetectDuplicateImages=true \
  "${ARGS}" "${FILE_NAME}"

NEW_SIZE=$(du -sk "${TEMP_OUTPUT}" | cut -f1)
NEW_SIZE_HUMAN=$(du -sh "${TEMP_OUTPUT}" | cut -f1)

SAVED_KB=$((ORIGINAL_SIZE - NEW_SIZE))
SAVED_MB=$(awk "BEGIN {printf \"%.2f\", ${SAVED_KB}/1024}")

printf "Original size:  %8s\n" "${ORIGINAL_SIZE_HUMAN}"
printf "Optimized size: %8s (%s MB saved)\n" "${NEW_SIZE_HUMAN}" "${SAVED_MB}"

if [[ -z "${OUTPUT_FILE}" ]]; then
  mv "${TEMP_OUTPUT}" "${FINAL_OUTPUT}"
fi
