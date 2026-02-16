#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <metrics_csv>"
  echo ""
  echo "Posts each metric from the CSV to the API metrics endpoint."
  echo ""
  echo "Environment:"
  echo "  LL_API_TOKEN — API bearer token (required)"
  echo "  LL_API_URL   — base URL (default: https://lifeledger.fly.dev)"
  exit 1
fi

if [[ -z "${LL_API_TOKEN:-}" ]]; then
  echo "Error: LL_API_TOKEN environment variable is not set" >&2
  exit 1
fi

BASE_URL="${LL_API_URL:-https://lifeledger.fly.dev}"
CSV_FILE="$1"
errors=0

{
  # Skip header row
  read -r _header

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Parse CSV fields (handles quoted values with commas)
    slug="" name="" units="" low="" high=""
    i=0
    remainder="$line"
    while [[ -n "$remainder" ]]; do
      if [[ "$remainder" == \"* ]]; then
        # Quoted field — extract up to closing quote
        remainder="${remainder:1}"
        field="${remainder%%\"*}"
        remainder="${remainder#*\"}"
        remainder="${remainder#,}"
      else
        field="${remainder%%,*}"
        if [[ "$remainder" == *,* ]]; then
          remainder="${remainder#*,}"
        else
          remainder=""
        fi
      fi

      case $i in
        0) slug="$field" ;;
        1) name="$field" ;;
        2) units="$field" ;;
        3) low="$field" ;;
        4) high="$field" ;;
      esac
      ((i++)) || true
    done

    [[ -z "$slug" ]] && continue

    json="{\"metric\":{\"slug\":\"${slug}\",\"name\":\"${name}\""
    [[ -n "$units" ]] && json="${json},\"units\":\"${units}\""
    [[ -n "$low" ]]   && json="${json},\"reference_min\":${low}"
    [[ -n "$high" ]]  && json="${json},\"reference_max\":${high}"
    json="${json}}}"

    response=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/api/metrics" \
      -H "Authorization: Bearer ${LL_API_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "$json")

    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')

    if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
      echo "OK  ${slug}"
    else
      echo "ERR ${slug} (HTTP ${http_code}): ${body}" >&2
      ((errors++)) || true
    fi
  done
} < "$CSV_FILE"

if [[ $errors -gt 0 ]]; then
  echo "${errors} metric(s) failed" >&2
  exit 1
fi
