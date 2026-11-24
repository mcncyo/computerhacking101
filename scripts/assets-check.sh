#!/usr/bin/env bash
# Usage: scripts/assets-check.sh <public-dir>  (production build). Catches regressions found in the Hextra port review.
set -uo pipefail
P="${1:?usage: assets-check.sh <public-dir>}"; fail=0; bad(){ echo "FAIL: $*"; fail=1; }
[ -f "$P/images/avatar.png" ] || bad "images/avatar.png missing (About page and author page use it)"
grep -q '^Sitemap: https://computerhacking101.com/sitemap.xml' "$P/robots.txt" 2>/dev/null || bad "robots.txt has no Sitemap line"
f="$P/404.html"
{ grep -q '<title' "$f" && grep -q 'href=https://computerhacking101.com/tutorials' "$f" && grep -qi 'not found' "$f"; } 2>/dev/null || bad "404.html is not a themed page with a title, navigation and a not-found message"
exit $fail
