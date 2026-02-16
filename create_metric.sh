#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <slug> <name> [options]"
  echo ""
  echo "Options:"
  echo "  --units <units>          e.g. lbs, ms, bpm, %"
  echo "  --min <value>            reference minimum"
  echo "  --max <value>            reference maximum"
  echo "  --lower-is-better        set delta_down_is_good to true"
  echo ""
  echo "Environment:"
  echo "  LL_API_TOKEN — API bearer token (required)"
  echo "  LL_API_URL   — base URL (default: https://ll.fly.dev)"
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

SLUG="$1"; shift
NAME="$1"; shift

UNITS=""
REF_MIN=""
REF_MAX=""
LOWER_IS_BETTER="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --units) UNITS="$2"; shift 2 ;;
    --min)   REF_MIN="$2"; shift 2 ;;
    --max)   REF_MAX="$2"; shift 2 ;;
    --lower-is-better) LOWER_IS_BETTER="true"; shift ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
done

if [[ -z "${LL_API_TOKEN:-}" ]]; then
  echo "Error: LL_API_TOKEN environment variable is not set" >&2
  exit 1
fi

BASE_URL="${LL_API_URL:-https://lifeledger.fly.dev}"

json="{\"metric\":{\"slug\":\"${SLUG}\",\"name\":\"${NAME}\",\"delta_down_is_good\":${LOWER_IS_BETTER}"
[[ -n "$UNITS" ]]   && json="${json},\"units\":\"${UNITS}\""
[[ -n "$REF_MIN" ]] && json="${json},\"reference_min\":${REF_MIN}"
[[ -n "$REF_MAX" ]] && json="${json},\"reference_max\":${REF_MAX}"
json="${json}}}"

response=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/api/metrics" \
  -H "Authorization: Bearer ${LL_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$json")

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
  echo "$body"
else
  echo "Error (HTTP $http_code): $body" >&2
  exit 1
fi
