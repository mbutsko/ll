#!/bin/bash
set -euo pipefail

API_URL="${API_URL:-https://lifeledger.fly.dev/api/weight_entries}"
BATCH_SIZE=100

if [ -z "${API_TOKEN:-}" ]; then
  echo "Usage: API_TOKEN=your_token ./post_weight.sh [path/to/weight.csv]"
  exit 1
fi

CSV_FILE="${1:-weight.csv}"

if [ ! -f "$CSV_FILE" ]; then
  echo "File not found: $CSV_FILE"
  exit 1
fi

entries=""
count=0
total=0

while IFS=, read -r date weight; do
  # Skip empty weights
  [ -z "$weight" ] && continue

  # Convert m/d/yyyy to yyyy-mm-dd
  month=$(echo "$date" | cut -d/ -f1)
  day=$(echo "$date" | cut -d/ -f2)
  year=$(echo "$date" | cut -d/ -f3)
  iso_date=$(printf "%04d-%02d-%02d" "$year" "$month" "$day")

  entry="{\"date\":\"$iso_date\",\"value\":$weight}"
  if [ -z "$entries" ]; then
    entries="$entry"
  else
    entries="$entries,$entry"
  fi
  count=$((count + 1))

  if [ "$count" -ge "$BATCH_SIZE" ]; then
    response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"entries\":[$entries]}")
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
    total=$((total + count))
    echo "Posted $total entries so far (HTTP $http_code): $body"

    if [ "$http_code" -ge 400 ]; then
      echo "Error: request failed"
      exit 1
    fi

    entries=""
    count=0
  fi
done < "$CSV_FILE"

# Post remaining entries
if [ "$count" -gt 0 ]; then
  response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"entries\":[$entries]}")
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')
  total=$((total + count))
  echo "Posted $total entries so far (HTTP $http_code): $body"

  if [ "$http_code" -ge 400 ]; then
    echo "Error: request failed"
    exit 1
  fi
fi

echo "Done. Total entries posted: $total"
