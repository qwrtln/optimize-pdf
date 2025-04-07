#!/usr/bin/env bash

FILE_NAME=$1
QUALITY=$2
CMYK=$3

EXTENSION="${FILE_NAME##*.}"
BASE_NAME="${FILE_NAME%.*}"
OUTPUT_FILE="${BASE_NAME}_optimized.${EXTENSION}"

if [[ -z "$QUALITY" ]]; then
  QUALITY="prepress"
fi

ARGS="-dPDFSETTINGS=/${QUALITY} -dDetectDuplicateImages=true"

if [[ "${CMYK}" == "true" ]]; then
  ARGS="${ARGS} -sColorConversionStrategy=CMYK"
fi

ORIGINAL_SIZE=$(du -sk "${FILE_NAME}" | cut -f1)
ORIGINAL_SIZE_HUMAN=$(du -sh "${FILE_NAME}" | cut -f1)

gs -o "${OUTPUT_FILE}" \
  -sDEVICE=pdfwrite \
  -dCompatibilityLevel=1.5 \
  "${ARGS}" \
  "${FILE_NAME}"

NEW_SIZE=$(du -sk "${OUTPUT_FILE}" | cut -f1)
NEW_SIZE_HUMAN=$(du -sh "${OUTPUT_FILE}" | cut -f1)

SAVED_KB=$((ORIGINAL_SIZE - NEW_SIZE))
SAVED_MB=$(awk "BEGIN {printf \"%.2f\", ${SAVED_KB}/1024}")

printf "Original size:  %8s\n" "${ORIGINAL_SIZE_HUMAN}"
printf "Optimized size: %8s (%s MB saved)\n" "${NEW_SIZE_HUMAN}" "${SAVED_MB}"

mv "${OUTPUT_FILE}" "${FILE_NAME}"
