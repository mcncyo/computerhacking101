#!/usr/bin/env bash
# Usage: scripts/home-check.sh <public-dir>   Exits 1 unless the built homepage has the required content and links.
set -uo pipefail
F="${1:?usage: home-check.sh <public-dir>}/index.html"
[ -f "$F" ] || { echo "no $F"; exit 1; }
fail=0
need() { grep -qF -- "$1" "$F" || { echo "MISSING: $1"; fail=1; }; }
need "Welcome to Computer"
for h in /tutorials/ /tutorials/home-automations/ /tutorials/servers/ /tutorials/docker/ /tutorials/security/ \
  /tutorials/home-automations/home-assistant/17-powerful-tips/ /tutorials/home-automations/home-assistant/top-15-automations/ /tutorials/home-automations/home-assistant/best-hardware/; do
  grep -qE "href=(\"|')?(https?://[^/]+)?${h}(\"|' |>| )" "$F" || { echo "MISSING link: $h"; fail=1; }
done
need "Why Trust Computer Hacking 101"
need "Browse All Tutorials"
exit $fail
