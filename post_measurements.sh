#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <metric_slug> <csv_file>"
  echo ""
  echo "CSV format: datetime,value,note"
  echo "  datetime — ISO 8601 (e.g. 2026-02-16 or 2026-02-16T08:30:00)"
  echo "  value    — numeric"
  echo "  note     — optional text"
  echo ""
  echo "Environment:"
  echo "  LL_API_TOKEN — API bearer token (required)"
  echo "  LL_API_URL   — base URL (default: https://ll.fly.dev)"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

SLUG="$1"
CSV_FILE="$2"

if [[ -z "${LL_API_TOKEN:-}" ]]; then
  echo "Error: LL_API_TOKEN environment variable is not set" >&2
  exit 1
fi

if [[ ! -f "$CSV_FILE" ]]; then
  echo "Error: file not found: $CSV_FILE" >&2
  exit 1
fi

BASE_URL="${LL_API_URL:-https://ll.fly.dev}"
BATCH_SIZE=50
batch="[]"
count=0
total=0
line_num=0

flush_batch() {
  if [[ "$batch" == "[]" ]]; then return; fi

  response=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/api/measurements" \
    -H "Authorization: Bearer ${LL_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"measurements\": ${batch}}")

  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [[ "$http_code" -ne 201 ]]; then
    echo "Error (HTTP $http_code): $body" >&2
    exit 1
  fi

  echo "$body"
  batch="[]"
  count=0
}

while IFS= read -r line || [[ -n "$line" ]]; do
  line_num=$((line_num + 1))

  # Skip empty lines and header rows
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[[:space:]]*(datetime|date|time) ]] && continue

  # Parse CSV fields (handle optional note)
  IFS=',' read -r dt value note <<< "$line"

  dt=$(echo "$dt" | xargs)
  value=$(echo "$value" | xargs)
  note=$(echo "${note:-}" | xargs)

  if [[ -z "$dt" || -z "$value" ]]; then
    echo "Skipping line $line_num: missing datetime or value" >&2
    continue
  fi

  # Build JSON entry
  entry="{\"slug\":\"${SLUG}\",\"datetime\":\"${dt}\",\"value\":${value}"
  if [[ -n "$note" ]]; then
    # Escape double quotes in note
    escaped_note=$(echo "$note" | sed 's/"/\\"/g')
    entry="${entry},\"notes\":\"${escaped_note}\""
  fi
  entry="${entry}}"

  # Append to batch
  if [[ "$batch" == "[]" ]]; then
    batch="[${entry}]"
  else
    batch="${batch%]},$entry]"
  fi

  count=$((count + 1))
  total=$((total + 1))

  if [[ $count -ge $BATCH_SIZE ]]; then
    flush_batch
  fi
done < "$CSV_FILE"

flush_batch

echo "Done. Sent $total measurements for '$SLUG'."
