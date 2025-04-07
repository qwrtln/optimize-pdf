#!/usr/bin/env bash

FILE_NAME=$1
QUALITY=$2
CMYK=$3
OUTPUT_FILE=$4

EXTENSION="${FILE_NAME##*.}"
BASE_NAME="${FILE_NAME%.*}"

if [[ -z "${OUTPUT_FILE}" ]]; then
  FINAL_OUTPUT="${FILE_NAME}"
  TEMP_OUTPUT="${BASE_NAME}_optimized.${EXTENSION}"
else
  FINAL_OUTPUT="${OUTPUT_FILE}"
  TEMP_OUTPUT="${OUTPUT_FILE}"
fi

if [[ -z "$QUALITY" ]]; then
  QUALITY="prepress"
fi

ARGS="-dPDFSETTINGS=/${QUALITY} -dDetectDuplicateImages=true"

if [[ "${CMYK}" == "true" ]]; then
  ARGS="${ARGS} -sColorConversionStrategy=CMYK"
fi

ORIGINAL_SIZE=$(du -sk "${FILE_NAME}" | cut -f1)
ORIGINAL_SIZE_HUMAN=$(du -sh "${FILE_NAME}" | cut -f1)

gs -o "${TEMP_OUTPUT}" \
  -sDEVICE=pdfwrite \
  -dCompatibilityLevel=1.5 \
  "${ARGS}" \
  "${FILE_NAME}"

NEW_SIZE=$(du -sk "${TEMP_OUTPUT}" | cut -f1)
NEW_SIZE_HUMAN=$(du -sh "${TEMP_OUTPUT}" | cut -f1)

SAVED_KB=$((ORIGINAL_SIZE - NEW_SIZE))
SAVED_MB=$(awk "BEGIN {printf \"%.2f\", ${SAVED_KB}/1024}")

printf "Original size:  %8s\n" "${ORIGINAL_SIZE_HUMAN}"
printf "Optimized size: %8s (%s MB saved)\n" "${NEW_SIZE_HUMAN}" "${SAVED_MB}"

if [[ -z "${OUTPUT_FILE}" ]]; then
  mv "${TEMP_OUTPUT}" "${FINAL_OUTPUT}"
fi
