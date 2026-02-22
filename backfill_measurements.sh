#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <measurements_csv>"
  echo ""
  echo "Reads a pivot-table CSV (slugs as rows, dates as columns)"
  echo "and posts each measurement via post_measurements.sh."
  echo ""
  echo "Environment:"
  echo "  LL_API_TOKEN — API bearer token (required)"
  echo "  LL_API_URL   — base URL (default: https://lifeledger.fly.dev)"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CSV_FILE="$1"
TMPDIR_BASE=$(mktemp -d)
trap 'rm -rf "$TMPDIR_BASE"' EXIT

# Read header row and convert m/d/y dates to YYYY-MM-DD
IFS= read -r header < "$CSV_FILE"
IFS=',' read -ra raw_dates <<< "$header"

dates=()
for ((i = 1; i < ${#raw_dates[@]}; i++)); do
  d="${raw_dates[$i]}"
  d=$(echo "$d" | xargs | tr -d '"')
  if [[ "$d" =~ ^([0-9]{1,2})/([0-9]{1,2})/([0-9]{2,4})$ ]]; then
    m="${BASH_REMATCH[1]}"
    day="${BASH_REMATCH[2]}"
    y="${BASH_REMATCH[3]}"
    [[ ${#y} -eq 2 ]] && y="20${y}"
    dates+=("$(printf '%04d-%02d-%02d' "$y" "$m" "$day")")
  else
    dates+=("$d")
  fi
done

total_slugs=0
total_measurements=0

# Process each data row
tail -n +2 "$CSV_FILE" | while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" ]] && continue

  # Parse slug (may be quoted)
  if [[ "$line" == \"* ]]; then
    slug="${line#\"}"
    slug="${slug%%\"*}"
    # Skip past closing quote and comma
    line="${line#*\",}"
  else
    slug="${line%%,*}"
    line="${line#*,}"
  fi

  [[ -z "$slug" ]] && continue

  # Build temp CSV for this slug
  tmpfile="${TMPDIR_BASE}/${slug}.csv"
  : > "$tmpfile"

  IFS=',' read -ra values <<< "$line"
  count=0
  for ((i = 0; i < ${#dates[@]}; i++)); do
    val="${values[$i]:-}"
    val=$(echo "$val" | xargs)
    # Skip empty or non-numeric values
    [[ -z "$val" ]] && continue
    [[ "$val" =~ ^-?[0-9]*\.?[0-9]+$ ]] || { echo "  skip ${slug} ${dates[$i]}: non-numeric '${val}'" >&2; continue; }
    echo "${dates[$i]},${val}" >> "$tmpfile"
    ((count++)) || true
  done

  if [[ $count -eq 0 ]]; then
    echo "SKIP ${slug} (no measurements)"
    continue
  fi

  echo "POST ${slug} (${count} measurements)"
  "${SCRIPT_DIR}/post_measurements.sh" "$slug" "$tmpfile"
  echo ""
done
