#!/usr/bin/env bash
# Usage: scripts/parity-check.sh <base-url>
# Exits 0 only if every path in scripts/parity/live-urls.txt returns 200 on <base-url>.
set -uo pipefail
BASE="${1:?usage: parity-check.sh <base-url>}"; BASE="${BASE%/}"
LIST="$(dirname "$0")/parity/live-urls.txt"
fail=0
while IFS= read -r path; do
  [ -z "$path" ] && continue
  code="$(curl -s -o /dev/null -m 20 -w '%{http_code}' "${BASE}${path}")"
  if [ "$code" != "200" ]; then echo "FAIL ${code} ${path}"; fail=$((fail+1)); fi
done < "$LIST"
echo "parity: $(wc -l < "$LIST") paths, ${fail} failing"
[ "$fail" -eq 0 ]
