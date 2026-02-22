#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <csv_file>"
  echo "Converts any m/d/y dates to YYYY-MM-DD, writes to stdout."
  exit 1
fi

convert_dates() {
  local s="$1"
  while [[ "$s" =~ ([0-9]{1,2})/([0-9]{1,2})/([0-9]{2,4}) ]]; do
    local m="${BASH_REMATCH[1]}"
    local d="${BASH_REMATCH[2]}"
    local y="${BASH_REMATCH[3]}"
    [[ ${#y} -eq 2 ]] && y="20${y}"
    local iso
    printf -v iso '%04d-%02d-%02d' "$y" "$m" "$d"
    s="${s/"${BASH_REMATCH[0]}"/$iso}"
  done
  printf '%s\n' "$s"
}

while IFS= read -r line || [[ -n "$line" ]]; do
  convert_dates "$line"
done < "$1"
